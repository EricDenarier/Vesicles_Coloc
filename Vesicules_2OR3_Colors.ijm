
var minSurface=0.02;
var maxSurface=1.5;
var VesiculeDiameter=5;
 
 
 macro "MaxAndSTD [F1]" {

 
run("Set Measurements...", "area mean standard limit display redirect=None decimal=3");
run("Options...", "iterations=1 count=1 black");

 setOption("JFileChooser", true); ///////////////// For El Capitan OSX to show the title needs imageJ 1.50e36.

	/////////////////////////////////////////	Choice of In and Out Directories 
 In = getDirectory("Choose a Directory for Original Images");
 Out = getDirectory("Choose a results Directory ");

Dialog.create("Choose your parameters");
Dialog.addNumber("Vesicules Diameter in pixel", VesiculeDiameter);
Dialog.addNumber("minSurface in µm2", minSurface);
Dialog.addNumber("MaxSurface in µm2", maxSurface);
Dialog.show();
VesiculeDiameter = Dialog.getNumber();
minSurface=Dialog.getNumber();
maxSurface=Dialog.getNumber();

list = getFileList(In);



for (i=0; i<list.length; i++) {
  	  	
	//////////////////// File Openning	
	
	run("Bio-Formats Importer", "open=["+In+list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	getDimensions(width, height, channels, slices, frames);
	
	Title=getTitle();shortName=split(File.nameWithoutExtension," ");//print (shortName[1]);
	setTool("polygon");	
	run("Enhance Contrast", "saturated=0.35");
	
	
	
	//////////////////// ROI drawing & measure of the surface
	
	waitForUser("Draw your ROI add to Manager and click OK when done");
	run("Select None");

	nROI=roiManager("count");

		for (k = 0; k < nROI; k++) {
			roiManager("select", k);
			run("Measure");
		}

		run("Select None");
	
		
		
	/////////////////// Filtering for vesicules amelioration
		
		filter (Title,"Median","Gaussian Blur",VesiculeDiameter/2,VesiculeDiameter*2);


	
	/////////////////////////////////////////	if 2 or 3 Channel
		if (channels==3) {

	/////////////////////////////////////////	Mask creation on each channels
	
			run("Split Channels");
			Mask("C1-filtered");
			Mask("C2-filtered"); 
			Mask("C3-filtered");

	/////////////////////////////////////////	Creation of Overlapping images
	
			imageCalculator("AND create", "C1-filtered","C2-filtered"); rename ("1and2");
			imageCalculator("AND create", "C1-filtered","C3-filtered"); rename ("1and3");
			imageCalculator("AND create", "C2-filtered","C3-filtered"); rename ("2and3");
			imageCalculator("AND create", "1and2","1and3"); rename ("1and2and3");
			run("Merge Channels...", "c1=C1-filtered c2=C2-filtered c3=C3-filtered create keep"); rename("Merge");

	/////////////////////////////////////////	Measure of surface of objects on every images

			nROI=roiManager("count");

				for (j = 0; j < nROI; j++) 
					{
	
					selectWindow("C1-filtered");
					roiManager("select", j);run("Duplicate...", "title=C1_ROI_"+j+"_"+shortName[1]);			
					setThreshold(255, 255);
					run("Analyze Particles...", "size=0-Infinity circularity=0.0-1.00 show=Nothing summarize");

					selectWindow("C2-filtered");
					roiManager("select", j);run("Duplicate...", "title=C2_ROI_"+j+"_"+shortName[1]);		
					setThreshold(255, 255);
					run("Analyze Particles...", "size=0-Infinity circularity=0.0-1.00 show=Nothing summarize");

					selectWindow("C3-filtered");
					roiManager("select", j);run("Duplicate...", "title=C3_ROI_"+j+"_"+shortName[1]);		
					setThreshold(255, 255);
					run("Analyze Particles...", "size=0-Infinity circularity=0.0-1.00 show=Nothing summarize");
	
					selectWindow("1and2");
					roiManager("select", j);run("Duplicate...", "title=C1and2_ROI_"+j+"_"+shortName[1]);		
					setThreshold(255, 255);
					run("Analyze Particles...", "size=0-Infinity circularity=0.0-1.00 show=Nothing summarize");

					selectWindow("1and3");
					roiManager("select", j);run("Duplicate...", "title=C1and3_ROI_"+j+"_"+shortName[1]);
					setThreshold(255, 255);
					run("Analyze Particles...", "summarize");

					selectWindow("2and3");
					roiManager("select", j);run("Duplicate...", "title=C2and3_ROI_"+j+"_"+shortName[1]);
					setThreshold(255, 255);
					run("Analyze Particles...", "summarize");

					selectWindow("1and2and3");
					roiManager("select", j);run("Duplicate...", "title=C123_ROI_"+j+"_"+shortName[1]);
					setThreshold(255, 255);
					run("Analyze Particles...", "summarize");
				
	
					}
			}

		if (channels==2) 
		{

		/////////////////////////////////////////	Mask creation on each channels
			run("Split Channels");
			Mask("C1-filtered");
			Mask("C2-filtered"); 
	
	/////////////////////////////////////////	Creation of Overlapping images

			imageCalculator("AND create", "C1-filtered","C2-filtered"); rename ("1and2");
	
			run("Merge Channels...", "c1=C1-filtered c2=C2-filtered  create keep"); rename("Merge");

	/////////////////////////////////////////	Measure of surface of objects on every images
			
			nROI=roiManager("count");

				for (j = 0; j < nROI; j++) {
	
					selectWindow("C1-filtered");
					roiManager("select", j);run("Duplicate...", "title=C1_ROI_"+j+"_"+shortName[1]);			
					setThreshold(255, 255);
					run("Analyze Particles...", "size=0-Infinity circularity=0.0-1.00 show=Nothing summarize");

					selectWindow("C2-filtered");
					roiManager("select", j);run("Duplicate...", "title=C2_ROI_"+j+"_"+shortName[1]);		
					setThreshold(255, 255);
					run("Analyze Particles...", "size=0-Infinity circularity=0.0-1.00 show=Nothing summarize");

			
	
					selectWindow("1and2");
					roiManager("select", j);run("Duplicate...", "title=C1and2_ROI_"+j+"_"+shortName[1]);		
					setThreshold(255, 255);
					run("Analyze Particles...", "size=0-Infinity circularity=0.0-1.00 show=Nothing summarize");
			
					}
	
				}



	/////////////////////////////////////////	Saving

	selectWindow("Merge");
run("From ROI Manager");
roiManager("reset");
saveAs("Tiff", Out+Title);run("Close All");


}
 selectWindow("Summary");
saveAs("Results", Out+shortName[1]+"_VesiculesData.tsv");run("Close");

selectWindow("Results");
saveAs("Results", Out+shortName[1]+"_ROIsize.tsv");run("Close");
 }

// End of MAcro
		
		
////////////////// Functions Filter and Mask		
		
		
function filter (image,filter1,filter2,size1,size2) {

selectWindow(image);

run("Duplicate...", "title=Low duplicate");
run("Duplicate...", "title=High duplicate"); 
if (filter1=="Median"){
selectWindow("Low");run(filter1+"...","radius="+size1+" stack");}
if (filter1=="Gaussian Blur"){
selectWindow("Low");run(filter1+"...","sigma="+size1+" stack");} 

if (filter2=="Median"){
selectWindow("High");run(filter2+"...","radius="+size2+" stack");}
if (filter2=="Gaussian Blur"){
selectWindow("High");run(filter2+"...","sigma="+size2+" stack");} 

imageCalculator("Subtract stack","Low","High");
close("High");
close(image);
selectWindow("Low"); rename ("filtered");
}

function Mask (image) {
selectWindow(image);run("Grays");
setAutoThreshold("Triangle dark");
waitForUser("Change the threshold and click OK");
run("Convert to Mask");
run("Analyze Particles...", "size="+minSurface+"-"+maxSurface+" circularity=0.50-1.00 show=Masks in_situ");
	
}