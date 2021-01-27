macro "OSOV Image Difference Auto" {

    run("OSOV Image Difference v2");
    run("Duplicate...", "duplicate");
    run("Convert to Mask");
    run("Synchronize Windows");
	run("Threshold...");

    while(!isKeyDown("space")){}
    
    run("Remove Outliers...");
	run("Tiff...");
	run("Set Measurements...", "area limit redirect=None decimal=3");
	run("Set Scale...", "distance=1 known=1 pixel=1 unit=cm");
	run("Threshold...");

	run("OSOV Measure Stack"); 
	saveAs("Results");
}