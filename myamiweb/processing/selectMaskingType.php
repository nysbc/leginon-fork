<?php
/**
 *	The Leginon software is Copyright 2003 
 *	The Scripps Research Institute, La Jolla, CA
 *	For terms of the license agreement
 *	see  http://ami.scripps.edu/software/leginon-license
 *
 *	refinement selection form
 */

require_once "inc/particledata.inc";
require_once "inc/leginon.inc";
require_once "inc/project.inc";
require_once "inc/processing.inc";

$expId = $_GET['expId'];
$formAction=$_SERVER['PHP_SELF']."?expId=$expId";

processing_header("Automated Masking Software Selection","Automated Masking Software Selection", $javascript,False);

// Selection Header
echo "<table border='0' width='640'>\n";
echo "<tr><td>\n";
echo "  <h2>Automated Masking Procedures</h2>\n";
echo "  <h4>\n";
echo "    Region masks can be created on images using automated methods. Automatically created masks can be assesed manually to accept or reject the result.  " 
	."During stack creation, particle selections within the assessed masks will not be considered for creating the stack. \n";
echo "  </h4>\n";
echo "</td></tr>\n";
echo "</table>\n";


echo "<br/>\n";
echo "<table border='1' class='tableborder' width='640'>\n";


/*
** Crud Finding
*/
echo "<tr><td width='100' align='center'>\n";
echo "  <img src='img/appionlogo.jpg' width='64'>\n";
echo "</td><td>\n";
echo "  <h3><a href='runMaskMaker.php?expId=$expId'>Crud Finding</a></h3>\n";
echo "<p>This is one of the original projection-matching refinement protocols, as implemented in "
	."<a href='http://blake.bcm.tmc.edu/eman/eman1/'>EMAN.</a>&nbsp;<img src='img/external.png'> It has been successfully "
	."tested on many different samples. Within each iteration, the raw particles are classified according to the angular "
	."sampling of projection directions, then iteratively aligned within each class to reduce the model bias. "
	."Further classification and particle 'filtering' has been incorporated using a SPIDER protocol that identifies "
	."and removes the particles with the highest variance (and therefore least correspondence) in the class using the "
	."<a href='http://www.wadsworth.org/spider_doc/spider/docs/man/cas.html'>"
	."CA S</a>&nbsp;<img src='img/external.png'> correspondence analysis operation in spider."
	."</p>\n";
echo "</td></tr>\n";

/*
** Maskiton
*/

echo "<tr><td width='100' align='center'>\n";
echo "  <img src='img/appionlogo.jpg' width='64'>\n";
echo "</td><td>\n";
echo "  <h3><a href='maskiton.php?expId=$expId'>Maskiton</a></h3>\n";
echo " <p> This is the <a href='http://xmipp.cnb.csic.es/twiki/bin/view/Xmipp/ProjectionMatchingRefinement'>
	Xmipp projection-matching refinement protocol.</a>&nbsp;<img src='img/external.png'> The classification of "
	."raw particles is done using the <a href='http://xmipp.cnb.csic.es/twiki/bin/view/Xmipp/Projection_matching'>
	angular projection matching</a>&nbsp;<img src='img/external.png'>&nbsp;"
	."operation in Xmipp. The user is given the option of employing an algebraic reconstruction technique "
	."(ART), weighted back-projection (WBP) or Fourier interpolation method to recontruct the computed classes from "
	."projection-matching. One big advantage to this protocol is speed. Because all Euler angle and alignment parameters "
	."are saved for each iteration of angular projection-matching, the later iterations localize the search space "
	."to an increasingly narrow region and, therefore, take significantly less cpu time to complete. "
	."</p>\n";
//echo "  <img src='img/align-smr.png' width='250'><br/>\n";
echo "</td></tr>\n";

/*
** Auto Masking
*/

echo "<tr><td width='100' align='center'>\n";
echo "  <img src='img/appionlogo.jpg' width='64'>\n";
echo "</td><td>\n";
echo "  <h3><a href='runAppionLoop.php?expId=$expId'>Auto Masking</a></h3>\n";
echo " <p> This is the <a href='http://www2.mrc-lmb.cam.ac.uk/relion/index.php/Main_Page'>
	Relion refinement protocol.</a>&nbsp;<img src='img/external.png'> "
	."This procedure implements so-called gold-standard FSC calculations, "
	."where two models are refined independently for two random halves of the data to prevent overfitting. Thereby, reliable resolution estimates and clean "
	."reconstructions are obtained without compromising reconstruction quality, see (Scheres & Chen, Nature Methods, in press) for more details. "
	."Note that for cyclic point group symmetries (i.e. C<n>), the two half-reconstructions are averaged up to 40 Angstrom resolution to prevent diverging orientations."
	."</p>\n";
//echo "  <img src='img/align-smr.png' width='250'><br/>\n";
echo "</td></tr>\n";



echo "</table>\n";
processing_footer();
exit;
