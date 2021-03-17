macro "OSOV Auto Embolism Detection" {
	
	// Macro Image Difference V2 
	// ---------------------------

	setBatchMode(true);

	originalImage = getImageID();

	Stack.getDimensions(width, height, channels, slices, frames);

	run("Make Substack..."," slices=1-"+ slices-1);
	imgID1 = getImageID();

	selectImage(originalImage);

	run("Make Substack...", " slices=2-"+ slices);
	imgID2 = getImageID();

	imageCalculator("Subtract create stack", imgID1, imgID2);
	
	selectImage(imgID1);
	close();

	selectImage(imgID2);
	close();
	// ---------------------------

	// Clear the images that will falsify the final result
	clearUnusableSlices();
	setSlice(1);

	setBatchMode("exit and display");

	// Threshold the stack to make it binary afterwards
	run("Threshold...");
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "Red");	

	// Waiting for Space key press
	while(!isKeyDown("space")){}

	// Remove noise
    run("Remove Outliers...");


	// Waiting for Space key press
	while(!isKeyDown("space")){}

	// Save As TIFF file format
    run("Tiff...");
	run("OSOV Auto Vulnerability Curve");
}


// Deletes the slices that falsify the results
function clearUnusableSlices(){
	maxPixelsMean = 5;
	for (sliceNumber = 1; sliceNumber < slices; sliceNumber++) {
		setSlice(sliceNumber);
		getStatistics(area, mean, min, max, std, histogram);
		if (mean > maxPixelsMean){
			setForegroundColor(0, 0, 0);
			run("Select All");
			run("Fill", "slice");
			run("Select None");
			sliceNumber--;
		}
	}
}

// Remove the black spots on a binary stack (not used because it takes some time and can remove some embolisms)
// stackTitle : title of the binary stack where we want to remove the black spots
// squareLength : length of the square to remove the black spots
function removeBlackSpots(stackTitle,squareLength){
	newSlicesNumber = nSlices();
	MaxWhitePixels = squareLength*2;
	for (sliceNumber = 1; sliceNumber <= newSlicesNumber; sliceNumber++){
		if (getTitle() != stackTitle){
			selectImage(stackTitle);
		}
		setSlice(sliceNumber);
		for (x = 0; x < width - squareLength; x = x+squareLength){
			for (y = 0; y < height - squareLength ; y = y+squareLength){
				whitePixels = 0;
				for (squareX = x; squareX < x + squareLength; squareX++){
					for (squareY = y; squareY < y + squareLength; squareY++){

						if (getPixel(squareX,squareY) == 0){
							whitePixels++;
						}
						if (whitePixels >= MaxWhitePixels){
							break;
						}
					}
					if (whitePixels >= MaxWhitePixels){
						break;
					}
				}
				if (whitePixels < MaxWhitePixels){
					for (squareX = x; squareX < x + squareLength; squareX++){
						for (squareY = y; squareY < y + squareLength; squareY++){
							setPixel(squareX,squareY,0);
						}
					}
				}
			}
		}
	}
}

