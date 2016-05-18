var dinty = require('dinty');

module.exports = {
    filterRow: function(row, trace) {
        // Ignore undefined gridrefs
        if (!row.gridRef) {
            trace("discarding as undefined grid ref");
            return;
        }


        var gridRef = row.gridRef;

        // trim whitespace
        gridRef.replace(/^\s+/, '');
        gridRef.replace(/\s+$/, '');
        gridRef = gridRef.toUpperCase();

        var len = gridRef.length;

        // Check for empties
        if (len == 0) {
            throw new Error("empty grid ref "+gridRef);
        }

        if (len < 5) {            
            trace("discarding as too coarse: "+gridRef);
            return;
        }
        
        // Check this gridref is valid, and convert to tetrad
        // precision
        row.tetrad = dinty.gridrefToTetrad(gridRef);
        row.gridRef = gridRef;

        return row;
    }

};