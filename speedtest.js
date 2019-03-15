function truncateFloat(val) {
	return Number(Number(val).toFixed(2))
}

function averageSlice(ary,pos) {
	var len = ary.length - 1;
	var tot = 0;
	for (var i=1; i < len; ++i)
	{
		tot += parseFloat(ary[i][pos], 10);
	}
	return truncateFloat(tot / len);
}

function drawVisualization() {
	$.get("speedtest.csv", function(csvString) {

		var convertToMbps = function(value,state) {
			if (isNaN(value)) {
				var ts = Date.parse(value);
				if (isNaN(ts)) {
					return value
				} else {
					return new Date(value)
				}
			}
			value = truncateFloat(value / (1024 * 1024));
			return Number(value);
		}
		// transform the CSV string into a 2-dimensional array
		var arrayData = $.csv.toArrays(csvString, {onParseValue: convertToMbps});

		// this new DataTable object holds all the data
		var data = new google.visualization.arrayToDataTable(arrayData);

		var s0Avg=averageSlice(arrayData, 1);
		var s1Avg=averageSlice(arrayData, 2);

		var chart = new google.visualization.ChartWrapper({
			chartType: 'LineChart',
			containerId: 'chart-div',
			dataTable: data,
			options:{
				title: arrayData[0][1] + " / " + arrayData[0][2] + " Speed (Mbps)",
				titleTextStyle : {color: 'grey', fontSize: 48},
				//curveType: 'function',
				animation: {
					startup: true,
					duration: 1500,
					easing: 'out'
				},
				vAxis: {
					viewWindow: {
						min: 0,
					},
				},
				hAxis: {
					gridlines: {
						count: -1,
						units: {
							days: {format: ['MMM dd']},
						},
					},
					minorGridlines: {
						units: {
							hours: {format: ['hh:mm a', 'ha']},
						},
					},
				},
				series: {
					0: {
						labelInLegend: arrayData[0][1] + " \u{1d4cd}\u0304 = " + s0Avg + " Mbps",
					},
					1 : {
						labelInLegend: arrayData[0][2] + " \u{1d4cd}\u0304 = " + s1Avg + " Mbps",
					},
				},
				legend: {
					position: 'top',
					alignment: 'start',
				},
        explorer: {
          maxZoomOut: 2,
          keepInBounds: true,
        },
			}
		});
		chart.draw();
	});
}
google.charts.setOnLoadCallback(drawVisualization)
