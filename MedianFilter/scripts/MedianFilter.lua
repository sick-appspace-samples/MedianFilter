--[[----------------------------------------------------------------------------

  Application Name: 
  MedianFilter                                                                                                             
  
  Summary:
  Applying median filter on scans read from a file
                                                                                    
  Description:  
  This sample shows how to apply a median filter to scans read 
  from file and displays the filtered scan as a point cloud. A file scan provider 
  is created and and the scans from the file are played back. The filtered scan is 
  shown in the PointCloud viewer on the webpage.

  How to run:
  Starting this sample is possible either by running the app (F5) or 
  debugging (F7+F10). Output is printed to the console and the transformed 
  point cloud can be seen on the viewer in the web page. The playback stops 
  after the last scan in the file. To replay, the sample must be restarted.
  To run this sample, a device with AppEngine >= 2.5.0 is required.
  
  Implementation: 
  To run with real device data, the file provider has to be exchanged with the 
  appropriate scan provider.
  
------------------------------------------------------------------------------]]
local counter = 0

--Start of Global Scope--------------------------------------------------------- 
local SCAN_FILE_PATH = "resources/TestScenario.xml"
print("Input File: ", SCAN_FILE_PATH)

-- Check device capabilities
assert(View,"View not available, check capability of connected device")
assert(Scan,"Scan not available, check capability of connected device")
assert(Scan.Transform,"Transform not available, check capability of connected device")
assert(Scan.MedianFilter,"MedianFilter not available, check capability of connected device")

-- Create a viewer instance
viewer = View.create()
assert(viewer,"Error: View could not be created")
viewer:setID("viewer3D")

-- Create a transform instance to convert the Scan to a PointCloud
transform = Scan.Transform.create()
assert(transform, "Transform could not be created")

-- Create the filter
medianFilter = Scan.MedianFilter.create()
assert(medianFilter,"MedianFilter could not be created")
Scan.MedianFilter.setType(medianFilter,"2D")
Scan.MedianFilter.setWidth(medianFilter, 3)
Scan.MedianFilter.setEchoNumber(medianFilter,0)
Scan.MedianFilter.setEnabled(medianFilter,true)

-- Create provider. Providing starts automatically with the register call
-- which is found below the callback function
provider = Scan.Provider.File.create()
assert(provider,"Scan provider could not be created")

Scan.Provider.File.setFile(provider, SCAN_FILE_PATH)
-- Set the DataSet of the recorded data which should be used.
Scan.Provider.File.setDataSetID(provider, 1)

--End of Global Scope----------------------------------------------------------- 

--Start of Function and Event Scope---------------------------------------------

-- Callback function to process new scans
function handleNewScan(scan)
  counter = counter + 1
  -- make one call to the filter 
  filteredScan = Scan.MedianFilter.filter(medianFilter, scan)
  -- plot filteres scan
  if ( nil ~= filteredScan ) then
    print("Show scan ", counter)
    -- Transform to PointCloud to view in the PointCloud viewer on the webpage
    local pointCloud = Scan.Transform.transformToPointCloud(transform, filteredScan)
    View.add(viewer, pointCloud)
    View.present(viewer)
  end
end
-- Register callback function to "OnNewScan" event. 
-- This call also starts the playback of scans
Scan.Provider.File.register(provider, "OnNewScan", "handleNewScan")

--End of Function and Event Scope------------------------------------------------