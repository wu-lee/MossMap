
(function(doc) {
    // Select only records
    if (doc._id.lastIndexOf('record=', 0) !== 0)
        return;
    
    for(var ix = 0; ix < doc.recordedBy.length; ix++) {
        emit([doc.dataSet, doc.taxon, doc.gridRef, doc.recordedOn, doc.recordedBy[ix]], {_id: doc.recordedBy[ix]});
    }
});
