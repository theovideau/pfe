macro "OSOV Image Difference Auto" {

    run("OSOV Image Difference v2");


    run("Duplicate...", "duplicate");
    run("Convert to Mask");
    run("Synchronize Windows");


}
	