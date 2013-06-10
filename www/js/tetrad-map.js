angular.module('TetradMapModule', ['ui.bootstrap']);



angular.module('TetradMapModule')
    .directive('tetradMap', function() {

	var aliasRx = /(\S*)\s*:\s*(\d+)\s*,\s*(\d+)/;
	var dateRx = /^(\d{4})(\d{2})?(\d{2})?$/;


	function Record(gridref, datestr) {
	    this.gridref = gridref;
	    this.datestr = datestr;
	    this.date = this.parseDate(datestr);
	}

	Record.prototype.parseDate = function(string) {
	    var d = dateRx.exec(string);
	    if (!d || d[2] > 12 || d[3] > 31) 
		throw new Error("malformed date string: "+string);

	    // Note Javascript month indexes are zero-based, so there is a -1 below.
	    var date = 
		!d[2]? { period: 'year', start: new Date(d[1]) } :
		!d[3]? { period: 'month', start: new Date(d[1], d[2]-1) } :
	        { period: 'day', start: new Date(d[1], d[2]-1, d[3]) } ;

	    return date;
	};

	Record.prototype.dateStr = function() {
	    var date = this.date.start;
	    var str = "";
	    switch (this.date.period) {
	    case "day":
		str = date.getDate();

	    case "month": 
		var month = [
		    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
		][date.getMonth()];
		str += " "+ month ;
		
	    case "year":
		str += " "+date.getFullYear();
	    }

	    return str;
	}

	// This function returns the last day of the period
	// following the start date.
	// The javascript date object attempts to auto-adjust to 
	// account for overflows and underflows of the input values.
	// So we can do the tricks below and come away with the correct date.
	Record.prototype.periodEnd = function() {
	    var date = new Date(this.date.start);
	    switch (this.date.period) {
	    case "year":
		date.setYear(date.getFullYear()+1);
		return date;
		
	    case "month":
		date.setMonth(date.getMonth()+1);
		return date;
		
	    default:
		return date;
	    };
	};

        return {
            scope: true, //{ val: '=' },
            link: function(scope, element, attrs) {

                var mapImg = attrs.tetradMap;
		var dataFile = attrs.taxonObservationData;
		var gridrefAlias1 = attrs.gridref1;
		var gridrefAlias2 = attrs.gridref2;
		var datasetVarName = attrs.datasetVar;

		scope.$parent[datasetVarName] = {}

		// FIXME error check

		var match = aliasRx.exec(gridrefAlias1);
		var alias1 = {
		    gridref: match[1],
		    img: {
			x: 1*match[2],
			y: 1*match[3],
		    },
		    map: gridrefToFalseOriginCoord(match[1])
		};

		match = aliasRx.exec(gridrefAlias2);
		var alias2 = {
		    gridref: match[1],
		    img: {
			x: 1*match[2],
			y: 1*match[3],
		    },
		    map: gridrefToFalseOriginCoord(match[1])
		};

		var dims = {
		    map: {
			width: alias2.map.x - alias1.map.x,
			height: alias2.map.y - alias1.map.y,
		    },
		    img: {
			width: alias2.img.x - alias1.img.x,
			height: alias2.img.y - alias1.img.y,
		    },
		};

		var scale = Math.sqrt(
		    (dims.img.width*dims.img.width + dims.img.height*dims.map.height) /
		    (dims.map.width*dims.map.width + dims.map.height*dims.map.height)
		);

		var map2img = {
		    scale: {
			x: scale,
			y: -scale,
		    },
		    offset: {
			x: 0+alias1.img.x - alias1.map.x*scale,
			y: 0+alias1.img.y + alias1.map.y*scale,
		    },
		    transform: function(coord) {
			return {
			    x: coord.x*this.scale.x + this.offset.x,
			    y: coord.y*this.scale.y + this.offset.y,
			    precision: coord.precision * Math.abs(this.scale.x)
			};
		    }
		};

		

		var svg = d3.select(element[0])
		    .append("svg")
		    .attr("height", "100%")
		    .attr("width", "100%")
		    .attr("preserveAspectRatio", "xMidYMid");

		var mapScaler = svg
		    .append("g")
		    .attr("id", "scaler")
		    .attr("transform", "scale(1)");

		var mapContainer = mapScaler
		    .append("g");

		var img = new Image();

		img.onload = function() {
		    var xoffset = -img.width*0.5;
		    var yoffset = -img.height*0.5;

		    svg
			.attr("viewBox",
			      xoffset+" "+yoffset+" "+
			      img.width+" "+img.height);

		    mapContainer
			.attr("transform", 
			      "translate("+xoffset+","+yoffset+")")
		    
			.insert("image", ":first-child")
			.attr("xlink:href", mapImg)
			.attr("height", img.height)
			.attr("width", img.width);
		};
		img.src = mapImg;

		var timeNow = new Date().getTime();

		d3.json(dataFile, function(json, err) {
		    if (err)
			throw new Error(err);

                    d3.select(mapContainer.node().childNodes).remove();

		    var taxaList = d3.entries(json);
		    scope.$parent[datasetVarName] = json;
		    scope.$parent.$digest();

		    var taxa = mapContainer
			.selectAll("g.taxon")
			.data(json)

			.enter()
			.append("g")
		    	.classed("taxon", true)
			.attr("taxon", function(d) { return d[0]; })
			.attr("width", "100%")
			.attr("height", "100%");

		    var markers = taxa
			.selectAll("circle")
			.data(function(d) { return d[1]; })

			.enter()
			.append("circle")
			.datum(function(d) {
			    var gridref = d[0];
			    var dates = d.slice(1);
			    var largest;
			    var largestDateString;

			    // Find the most recent record, i.e. that whose last day
			    // of the period within the precision of the date is latest.
			    var latest, latestRecord;
			    var records  = dates.map(function(date) {
				var record = new Record(gridref, date);
				var end = record.periodEnd();
				if (!latest || latest < end) {
				    latest = end;
				    latestRecord = record;
				}
				return record;
			    });
			    var text = records.length+" records @"+gridref+
				" latest at "+latestRecord.dateStr();

			    var ageIx = Math.pow(2, (latest.getTime() - timeNow)/1000000000000);
			    return {
				gridref: gridref,
				coord: map2img.transform(gridrefToFalseOriginCoord(gridref)),
				text: text,
				age: ageIx
			    };
			})
			.attr("cx", function(d) { return d.coord.x + d.coord.precision*0.5 })
			.attr("cy", function(d) { return d.coord.y + d.coord.precision*0.5 })
			.attr("r", function(d) { return d.coord.precision*0.5 })
			.attr("fill", function(d) {
			    var hex1 = Math.floor(d.age * 0xf).toString(16);
			    var hex2 = Math.floor((1-d.age) * 0xf).toString(16);
			    return "#"+hex2+hex1+"0";
			})
			.attr("title", function(d) { return d.text; })
		});
            }
        }
    });



function Controller($scope) {
    $scope.taxon = '';

    $scope.$watch('taxon', function(newValue, oldValue) {
	console.log(oldValue+" -> "+newValue);
	if (oldValue === newValue)
	    return;
	oldValue && d3.selectAll('g[taxon="'+oldValue[0]+'"]').style("display", "none");
	newValue && d3.selectAll('g[taxon="'+newValue[0]+'"]').style("display", "inherit");
    });
}
