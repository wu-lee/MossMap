angular.module('TetradMapModule', ['ui.bootstrap']);



angular.module('TetradMapModule')
    .directive('tetradMap', function() {

	var aliasRx = /(\S*)\s*:\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)/;
	var dateRx = /^(\d{4})(\d{2})?(\d{2})?$/;


        function DateThreshold(thresholds, defaultVal) {
            this.default = defaultVal;
            if (!(thresholds instanceof Object))
                throw new Error("thresholds parameter must be an object");

            this.thresholds = 
                Object.keys(thresholds).map(function(key) {
                    var date = thresholds[key];
                    if (!(date instanceof Date))
                        throw Error("threshold['"+key+"'] is not "+
                                    "a Date (it is: "+date+")");

                    return {
                        date: date,
                        key: key
                    };
                });

            this.thresholds.sort(function(a, b) {
                return ((a.date < b.date)? -1:
                        (a.date > b.date)? +1:
                        0);
            });
        }

        DateThreshold.prototype.get = function(date) {
            for(var ix = 0; ix < this.thresholds.length; ix += 1) {
                var threshold = this.thresholds[ix];
                if (date < threshold.date)
                    return threshold.key;
            }
            return this.default;
        };

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

                var options = scope.$eval(attrs.tetradMap);

                var mapImg = options.image;
		var dataFile = options.taxonObservationData;
		var gridrefAlias1 = options.gridref1;
		var gridrefAlias2 = options.gridref2;
		var datasetVarName = options.datasetVar;
                var zoomExpr = options.zoomExpr || 1;
		var dateThresholds = new DateThreshold(
                    options.dateThresholds || {}, 'p0'
                );

                                                   
		scope.$parent[datasetVarName] = {}

		// FIXME error check
                var body = d3.select('body');

                // Hand-roll some tooltip functionality using d3 since
                // angular $compiling a tooltip into all the elements
                // we're about to add is hopelessly slow.
                function showTooltip(d, i) {
                    var bbox = this.getBoundingClientRect();
                    var inner;
                    var tooltip = body
                        .select('body > div.tooltip');

                    if (tooltip.empty()) {

                        tooltip = body
                            .append('div')
                            .attr('class', 'tooltip top')
                            .datum(function() {
                                // This is inside a .datum() so it
                                // only gets fired once when the tooltip
                                // is created
                                var tooltip = d3.select(this);
                                tooltip
                                    .append('div')
                                    .attr('class', 'tooltip-arrow');
                                
                                inner = tooltip
                                    .append('div')
                                    .attr('class', 'tooltip-inner');
                            });
                    }
                    else {
                        inner = tooltip.select('.tooltip-inner');
                    }

                    inner
                        .text(d.text); // FIXME sanitise

                    var tooltipNode = tooltip[0][0];
                    var ttWidth = tooltipNode.offsetWidth;
                    var ttHeight = tooltipNode.offsetHeight;
                    var left = bbox.left + bbox.width/2 - ttWidth/2;
                    var top = bbox.top - ttHeight;

                    tooltip
                        .attr('style', 'top: '+top+'px; left: '+left+'px;');
                    
                    tooltip
                        .transition()
                        .style('opacity', 100)
                 };

                function hideTooltip() {
                    body.selectAll('.tooltip')
                        .transition()
                        .style('opacity', 0)
                        .remove();
                };

                function move(pos) {
                    return function(d, i) {
                        d3.event.preventDefault();

                        var newpos = d3.mouse(this.parentNode);
                        var x = newpos[0] - pos[0];
                        var y = newpos[1] - pos[1];

                        d3.select(this)
                            .attr('transform', 'translate('+x+','+y+')');
                    };
                };

                function drop() {
                    var map = d3.select(this);
                    map.on('mousemove', null);
                };

                function grab(d, i) {
                    d3.event.preventDefault();
                    var map = d3.select(this);
                    var pos = d3.mouse(this.parentNode);

                    // Subtract the current map offset from the mouse
                    // position
                    var matrix = this.getTransformToElement(this.parentNode);
                    pos[0] -= matrix.e;
                    pos[1] -= matrix.f;

                    map
                        .on('mousemove', move(pos))
                        .on('mouseout', drop)
                        .on('mouseup', drop);
                };


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
		    (dims.img.width*dims.img.width + dims.img.height*dims.img.height) /
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
		    .attr("width", "100%");

                var mapSvg = svg
                    .append('svg')
		    .attr("preserveAspectRatio", "xMidYMid");

		var mapScaler = mapSvg
		    .append("g")
		    .attr("id", "scaler")
		    .attr("transform", "scale(1)");

		var mapMover = mapScaler
		    .append("g")
		    .attr("id", "mover");

		var mapContainer = mapMover
		    .append("g");


                mapMover
                    .on('mousedown', grab);


                // Legend

                var legend = svg
                    .append("g")
                    .attr("class", "legend")
                    .attr("transform", "translate(20,20)");

                // Convert the dateThresholds into a legend We append
                // items for a) recordings since the final threshold
                // date, and b) completed tetrad markers.
                var legend_data = dateThresholds.thresholds
                    .map(function(it) { 
                        return [ it.key, 
                                 "Recordings before "+
                                 (it.date.getYear()+1900) ];
                    })
                    .concat([[ dateThresholds.default, 
                               "Recordings since "+
                               (dateThresholds.thresholds
                                .slice(-1)[0].date.getYear()+1900) ],
                             [ "completed", "Survey effort satisfactory" ]])
                    .reverse();

                var legend_items = legend
                    .selectAll("g.legend g")
                    .data(legend_data)
                    .enter()
                    .append("g")
                    .attr("transform", function(d,i) {
                        return "translate(0,"+(i*15)+")";
                    });

                legend_items
                    .append("circle")
                    .attr("r", function(d) { return d[0] === "completed"? 2 : 5 })
                    .attr("class", function(d) { return d[0] });
                legend_items
                    .append("text")
                    .attr("x", "1em")
                    .attr("dy", "0.32em")

                    .text(function(d) { return d[1]; });

                var legendBBox = legend.node().getBBox();
                legendBBox.x -= 5;
                legendBBox.y -= 5;
                legendBBox.width += 10;
                legendBBox.height += 10;

                legend
                    .insert("rect", ":first-child")
                    .attr("fill", "white")
                    .attr("stroke", "green")
                    .attr("x",legendBBox.x)
                    .attr("y",legendBBox.y)
                    .attr("rx",5)
                    .attr("ry",5)
                    .attr("width",legendBBox.width)
                    .attr("height",legendBBox.height);
                



                // Load the map image, transform it

		var img = new Image();

		img.onload = function() {
		    var xoffset = -img.width*0.5;
		    var yoffset = -img.height*0.5;

		    mapSvg
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

                // This updates the zoom when the zoomExpr changes
                scope.$watch(zoomExpr, function(newVal, oldVal) {
                    mapScaler
		        .attr("transform", "scale("+(1+newVal*newVal/100)+")");
                });

		var timeNow = new Date().getTime();

		d3.json(dataFile, function(err, json) {
		    if (err)
			throw new Error(err);

                    d3.select(mapContainer.node().childNodes).remove();

		    scope.$parent[datasetVarName] = json;
		    scope.$parent.$digest();

		    var taxa = mapContainer
			.selectAll("g.taxon")
			.data(json.taxa)

			.enter()
			.append("g")
		    	.classed("taxon", true)
			.attr("taxon", function(d) { return d[0]; })
			.attr("width", "100%")
			.attr("height", "100%");

		    var markers1 = taxa
			.selectAll("circle")
			.data(function(d) { return d[1]; })

			.enter()
			.append("circle")
			.datum(function(d) {
			    var gridref = d[0];
			    var dates = d[1];
			    var largest;
			    var largestDateString;

			    // Find the most recent record, i.e. that whose last day
			    // of the period within the precision of the date is latest.
			    var latest, latestRecord, count = 0;
                            for(var date in dates) {
                                if (!dates.hasOwnProperty(date))
                                    continue;
			        
				var record = new Record(gridref, date);
				var end = record.periodEnd();
				if (!latest || latest < end) {
				    latest = end;
				    latestRecord = record;
				}
                                count += dates[date];
			    }
			    var text = count+" records @"+gridref+
				" latest at "+latestRecord.dateStr();

			    return {
				gridref: gridref,
				coord: map2img.transform(gridrefToFalseOriginCoord(gridref)),
				text: text,
                                latestRecord: latestRecord,
			    };
			})
			.attr("cx", function(d) { return d.coord.x + d.coord.precision*0.5 })
			.attr("cy", function(d) { return d.coord.y - d.coord.precision*0.5 })
			.attr("r", function(d) { return d.coord.precision*0.5 })
			.attr("class", function(d) {
                            return dateThresholds.get(d.latestRecord.periodEnd());
			})
                        .on("mouseenter", showTooltip)
                        .on("mouseleave", hideTooltip);

                    var completed = mapContainer
                        .selectAll("g.completed")
                        .data([json.completed])
                        .enter()
                        .append("g")
                        .classed("completed", true)
			.attr("width", "100%")
			.attr("height", "100%");


                    var completedRadius = 3;
		    var markers2 = completed
			.selectAll("circle")
			.data(function(d) { return d; })

			.enter()
			.append("circle")
			.datum(function(gridref) {
                            return map2img.transform(gridrefToFalseOriginCoord(gridref));
			})
			.attr("cx", function(coord) { return coord.x + coord.precision*0.5 })
			.attr("cy", function(coord) { return coord.y - coord.precision*0.5 })
			.attr("r", function(coord) { return completedRadius });
		});
            }
        }
    });



function Controller($scope) {
    $scope.taxon = '';
    $scope.zoom = 0;

    $scope.$watch('taxon', function(newValue, oldValue) {
	if (oldValue === newValue)
	    return;
	oldValue && d3.selectAll('g[taxon="'+oldValue[0]+'"]').style("display", "none");
	newValue && d3.selectAll('g[taxon="'+newValue[0]+'"]').style("display", "inherit");
    });


    $scope.mapOptions = {
        image: "basemap.jpg",
        taxonObservationData: "cheshire-dataset.json",
	datasetVar: "dataset",
        dateThresholds: {p1: new Date(2000,0,1),
                         p2: new Date(1950,0,1)},
        zoomExpr: "zoom",
	gridref1: "SD20:29.5,75.5",
        gridref2: "SK14:1092.5,784",
    };
}
