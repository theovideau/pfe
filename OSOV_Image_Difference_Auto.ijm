macro "OSOV Image Difference Auto" {

    run("OSOV Image Difference v2", "Leaf");
    run("Duplicate...", "duplicate");
    run("Convert to Mask");

	//while(!isKeyDown("space")){}


    run("Remove Outliers...");
    run("Tiff...");
    run("Set Measurements...", "area limit redirect=None decimal=3");
    run("Set Scale...", "distance=1 known=1 pixel=1 unit=cm");

	//while(!isKeyDown("space")){}
    run("OSOV Measure Stack");

    FileCCValuesPath=File.openDialog("Select the file containing the coordinates");

	area = newArray(nResults);
    sum = newArray(nResults);
    sum[0] = 0;
    for (i=0; i < nResults; i++) {
        xValue = getResult("Area", i);
        area[i] = xValue;
		if(i==0){
			sum[i] = xValue;
		}else{
			sum[i] = sum[i-1] + xValue;
		}

    }
	run("Clear Results");
	if (isOpen("Results")) {
         selectWindow("Results");
         run("Close" );
	}
	importResult(FileCCValuesPath);

	time = newArray(nResults);
	for (i=0; i < nResults; i++) {
		xValue = getResult("date_hour",i);
		time[i] = xValue;
	}

	phi = newArray(nResults);
	for (i=0; i < nResults; i++) {
		xValue = getResult("phi",i);
		phi[i] = xValue;
	}


	Plot.create("Plot of Results", "time", "phi");
	Plot.add("Circle", time, phi);
	Plot.setStyle(0, "blue,#a0a0ff,1.0,Circle");
	Fit.doFit("Straight Line", time, phi);
	slope = Fit.p(0);
	intercept = Fit.p(1);
	Fit.plot();

	tab = newArray(nResults);
	for (i=0; i < nResults; i++) {
		tab[i] = phi[i] * slope + intercept;
	}


	tab2 = newArray(nResults);
	for (i=0; i < nResults; i++) {
		tab2[i] = sum[i] / sum[nResults-1] * 100;
	}


	phi2 = newArray(nResults);
	for (i=0; i < nResults; i++) {
		phi2[i] = -phi[i];
	}

	Plot.create("Plot of Results", "tab2", "phi2");
	Plot.add("Circle", phi2, tab2);
	Plot.setStyle(0, "blue,#a0a0ff,1.0,Circle");

}


function importResult(path) {
	 requires("1.35r");
     lineseparator = "\n";
     cellseparator = ";\t";

     // copies the whole RT to an array of lines
     lines=split(File.openAsString(path), lineseparator);

     // recreates the columns headers
     labels=split(lines[0], cellseparator);
     if (labels[0]==" ")
        k=1; // it is an ImageJ Results table, skip first column
     else
        k=0; // it is not a Results table, load all columns
     for (j=k; j<labels.length; j++)
        setResult(labels[j],0,0);

     // dispatches the data into the new RT
     run("Clear Results");
     for (i=1; i<lines.length; i++) {
        items=split(lines[i], cellseparator);
        for (j=k; j<items.length; j++)
           setResult(labels[j],i-1,items[j]);
     }
     updateResults();
}
