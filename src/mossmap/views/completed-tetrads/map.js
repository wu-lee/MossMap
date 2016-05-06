
(function(doc) {
    // Select only records
    if (doc._id.lastIndexOf('completed=', 0) !== 0)
        return;
    
    emit([doc.dataSet, doc.gridRef]);
});
