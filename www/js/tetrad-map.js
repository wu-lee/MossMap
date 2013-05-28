angular.module('TetradMapModule', []);



angular.module('TetradMapModule')
    .directive('tetradMap', function() {

	var aliasRx = /(\S*)\s*:\s*(\d+)\s*,\s*(\d+)/;

        return {
            scope: true, //{ val: '=' },
            link: function(scope, element, attrs) {

                var mapImg = attrs.tetradMap;
		var dataFile = attrs.taxonObservationData;
		var gridrefAlias1 = attrs.gridref1;
		var gridrefAlias2 = attrs.gridref2;

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
//		    .style("background-image", "url("+mapImg+")");
		;

		var mapG = svg
		    .append("g")
/*		    .attr("transform",
			  "scale("+map2img.scale.x+","+map2img.scale.y+") "+
			  "translate("+map2img.offset.x+","+map2img.offset.y+")");
*/
		;
		var img = new Image();

		img.onload = function() {
		    var image = svg
			.attr("height", img.height)
			.attr("width", img.width)
			.insert("image", ":first-child")
			.attr("xlink:href", mapImg)
			.attr("height", img.height)
			.attr("width", img.width);

//		    img = image;
		};
		img.src = mapImg;

		d3.json(dataFile, function(json, err) {
		    if (err)
			throw new Error(err);

                    d3.select(mapG.node().childNodes).remove();

		    var taxaList = d3.entries(json);

		    var taxa = mapG
			.selectAll("g.taxon")
			.data(taxaList)

			.enter()
			.append("g")
		    	.classed("taxon", true)
			.attr("taxon", function(d) { return d.key; })
			.attr("width", "100%")
			.attr("height", "100%");

		    var markers = taxa
			.selectAll("circle")
			.data(function(d) { return d3.entries(d.value); })

			.enter()
			.append("circle")
			.datum(function(d) { return map2img.transform(gridrefToFalseOriginCoord(d.key)); })
			.attr("cx", function(d) { return d.x + d.precision*0.5 })
			.attr("cy", function(d) { return d.y + d.precision*0.5 })
			.attr("r", function(d) { return d.precision*0.5 })
			.attr("fill", "red")


		});
            }
        }
    });



function Controller() {

}