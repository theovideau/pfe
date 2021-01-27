macro "OSOV Image Difference Auto" {

    run("OSOV Image Difference v2");
    run("Duplicate...", "duplicate");
    run("Convert to Mask");
    run("Synchronize Windows");
	
	bool = isKeyDown("space");
	while(!bool){
		bool = isKeyDown("space");
	}
	run("Remove Outliers...");
}
	