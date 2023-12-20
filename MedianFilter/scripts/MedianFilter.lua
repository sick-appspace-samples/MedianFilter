
--Start of Global Scope---------------------------------------------------------
local counter = 0
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

---Callback function to process new scans
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