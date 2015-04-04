<?php
/**
 *	The Leginon software is Copyright 2003 
 *	The Scripps Research Institute, La Jolla, CA
 *	For terms of the license agreement
 *	see  http://ami.scripps.edu/software/leginon-license
 *
 *	Simple viewer to view a image using mrcmodule
 */

require_once "inc/particledata.inc";
require_once "inc/leginon.inc";
require_once "inc/project.inc";
require_once "inc/processing.inc";

$expId = $_GET['expId'];
$formAction=$_SERVER['PHP_SELF']."?expId=$expId";
$_SESSION['erase_coarse'] = 0;
$_SESSION['erase_refine'] = 0;

processing_header("Align Tilt Series","Align Tilt Series Page", $javascript,False);

// Selection Header
echo "<table border='0' width='640'>\n";
echo "<tr><td>\n";
echo "  <h2>Tilt Series Alignment Procedures</h2>\n";
echo "  <h4>\n";
echo "    Tilt series may have been made with or without \n"
	."fiducial markers. Some tilt series are amenable \n"
	."to automated alignment while others require (some) \n"
	."manual alignment.";
echo "  <h4>\n";
echo "    The idea with Protomo and eTomo \n"
        ."is for the user to work through aligning a single tilt \n"
        ."series in a session, then use the parameters that \n"
        ."produce acceptable results on the entire tilt series \n"
        ."session using 'Batch align tilt series' from the left menu. \n";
echo "  <h4>\n";
echo "    <i>(The following workflows use PHP sessions to keep track of \n"
        ."variables. They are designed to be used from start to finish \n"
        ."in a browser independent of all other Appion queries.)</i>";
echo "  </h4>\n";
echo "</td></tr>\n";
echo "</table>\n";


echo "<br/>\n";
echo "<table border='1' class='tableborder' width='640'>\n";

/*
** Protomo 2.4.1
*/

echo "<tr><td width='100' align='center'>\n";
echo "  <img src='img/protomo.png' width='120'>\n";
echo "</td><td>\n";
echo "  <h3><a href='runAppionLoop.php?expId=$expId&form=Protomo2CoarseAlignForm'>Protomo 2.4.1</a></h3>\n";
echo " <p> Protomo is a software package used in electron tomography for marker-free alignment and 3D "
	."reconstruction of tilt series. The marker-free alignment is based on cross-correlation methods and "
	."projection matching. It also includes the refinement of geometric parameters of the tilt series. "
	."3D reconstruction is carried out by weighted back-projection with general weighting functions "
	."that allow varying tilt angle increments. ";
echo "</td></tr>\n";

/*
** eTomo 4.8.13 Dev.
*/

echo "<tr><td width='100' align='center'>\n";
echo "  <img src='' width='96'>\n";
echo "</td><td>\n";
echo "  <h3><a href='runEtomo.php?expId=$expId'>eTomo - Not Yet Implemented!</a></h3>\n";
echo " <p>Here eTomo is operated completely through the command line using batchruntomo. "
	."Batchruntomo runs all the operations required to align a tilt series and build a tomogram. "
	."Batchruntomo can work on more than one data set and can run on multiple local processors and GPUs. "
	."</p>\n";
echo "</td></tr>\n";


/*
** Old software
*/

echo "<tr><td width='100' align='center'>\n";
		echo "  <img src='img/other_software.png' width='125'>\n";
echo "</td><td>\n";
echo "  <h3><a href='runTomoAligner.php?expId=$expId'>Other Software Packages</a></h3>\n";
echo " <p>Here you will find older and unmaintained software packages for aligning tilt series, "
	."including Leginon alignment, Protomo 1 refinement, and Imod shift-only alignment. "
	."</p>\n";
echo "</td></tr>\n";



echo "</table>\n";
processing_footer();
exit;
