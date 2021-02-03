var SAMPLE_TYPE_STEM = "Stem";
var SAMPLE_TYPE_LEAF = "Leaf";

var sampleType;

macro "OSOV Image Difference Auto" {
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


    run("Duplicate...", "duplicate");
	run("Convert to Mask", "method=Moments background=Dark");
    //run("Synchronize Windows");
	run("Threshold...");

    //while(!isKeyDown("space")){}
    
    run("Remove Outliers...", "add stack");
	run("Tiff...");
	run("Set Measurements...", "area limit redirect=None decimal=3");
	run("Set Scale...", "distance=1 known=1 pixel=1 unit=cm");
	run("Threshold...");	//setAutoThreshold("Default dark");

	run("OSOV Measure Stack"); 
	//saveAs("Results");

	FileCCValuesPath=File.openDialog("Select the file containing the coordinates");
	//open(FileCCValuesPath);

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
	//run("Results...", FileCCValuesPath);
	//updateResults();
	
	time = newArray(nResults);
	for (i=0; i < nResults; i++) {
		xValue = getResult("date_hour",i);
		time[i] = xValue;
	}	

	Array.show(sum);
	Array.show(time);
    




}


function getSettings() {
	sampleType = SAMPLE_TYPE_LEAF;
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