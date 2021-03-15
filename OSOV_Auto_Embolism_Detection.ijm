var SAMPLE_TYPE_STEM = "Stem";
var SAMPLE_TYPE_LEAF = "Leaf";

var sampleType;

macro "OSOV Auto Embolism Detection" {
	
	// Macro Image Difference V2 
	// ---------------------------
	getSettings();

	setBatchMode(true);

	originalImage = getImageID();

	Stack.getDimensions(ww, hh, channels, slices, frames);

	run("Make Substack..."," slices=1-"+ slices-1);
	imgID1 = getImageID();

	selectImage(originalImage);

	run("Make Substack...", " slices=2-"+ slices);
	imgID2 = getImageID();

	if(sampleType == SAMPLE_TYPE_STEM) {
		imageCalculator("Subtract create stack", imgID2, imgID1);
	} else {
		imageCalculator("Subtract create stack", imgID1, imgID2);
	}
	selectImage(imgID1);
	close();

	selectImage(imgID2);
	close();

	setBatchMode("exit and display");
	// ---------------------------

	// Convert Stack to Binary
	run("Convert to Mask");

	// Waiting for Space key press
	while(!isKeyDown("space")){}

	// Remove Outliers
    run("Remove Outliers...");

	// Waiting for Space key press
	while(!isKeyDown("space")){}

	// Save As TIFF file format
    run("Tiff...");

	// Set Measurements with parameters
    run("Set Measurements...", "area limit redirect=None decimal=3");

	// Set Scale with parameters 1:1
    run("Set Scale...", "distance=1 known=1 pixel=1 unit=cm");

	// Run Measurements from Stack
    run("OSOV Measure Stack");

	// Window dialog for select the Bilan csv file
  	FileCCValuesPath=File.openDialog("Select the csv file...");

	// Areas and cumulative area total array
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

	// Clear results window 
	run("Clear Results");
	if (isOpen("Results")) {
        selectWindow("Results");
        run("Close");
	}

	// Import "Bilan" with water potential csv file
	importResult(FileCCValuesPath);

	// Get time from csv file (here )
	time = newArray(nResults); 
    Array.fill(time, 0);
	for (i=1; i < nResults; i++) {
		//xValue = getResult("date_hour",i); // time format from csv file is invalid and does not work
		time[i] += 5*i;
	}

	// Get water potential (phi) from csv file
	phi = newArray(nResults);
	for (i=0; i < nResults; i++) {
		xValue = getResult("phi",i);
		phi[i] = xValue;
	}

	// Water potential versus time curve
	Plot.create("Courbe du potentiel hydrique en fonction du temps", "time", "phi");
	Plot.add("Circle", time, phi);
	Plot.setStyle(0, "blue,#a0a0ff,1.0,Circle");

	// 2nd order linear regression
	Fit.doFit(2, time, phi);
	a = Fit.p(0);
	b = Fit.p(1);
    c = Fit.p(2);
    d = Fit.p(3);
	Fit.plot();

	// Water potential from linear regression : solve a+bx+cx^2+dx^3
	PH = newArray(nResults);
	for (i=0; i < nResults; i++) {
        t = time[i];
		PH[i] = (a + t*b + t*t*c + t*t*t*d);
	}

	// Calculation of the cumulative area
	cumulativeArea = newArray(nResults);
	for (i=0; i < nResults; i++) {
		cumulativeArea[i] = sum[i] / sum[nResults-1] * 100;
	}

	// Opposite of water potential
	phi2 = newArray(nResults);
	for (i=0; i < nResults; i++) {
		phi2[i] = -phi[i];
	}

	// Final curve : cavitation vulnerability curve
	Plot.create("Courbe de vulnérabilité à la cavitation", "Potentiel Hydrique", "Pourcentage d'embolie");
	Plot.add("Circle", PH, cumulativeArea);
	Plot.setStyle(0, "blue,#a0a0ff,1.0,Circle");
}

// Import results fonction from csv file
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

function getSettings() {
	sampleType = SAMPLE_TYPE_LEAF;
}