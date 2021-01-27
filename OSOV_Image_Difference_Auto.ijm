macro "OSOV Image Difference Auto" {

    run("OSOV Image Difference v2");
    run("Duplicate...", "duplicate");
    run("Convert to Mask");
    run("Synchronize Windows");
	run("Threshold...");

    while(!isKeyDown("space")){}
    
    run("Remove Outliers...");
	run("Tiff...");
	run("Set Measurements...");
	run("Set Scale...");
	run("Threshold...");

	run("OSOV Measure Stack"); 
	saveAs("Results");




}