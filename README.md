# Photogrammetry App
This is the iOS copmanion app for [photogrammetry-api](https://github.com/sbwp/photogrammetry-api).

## Compatibility
It has only been tested on the iPhone 13 Pro Max. It should work on the iPhone 12 Pro, iPhone 12 Pro Max, and iPhone 13 Pro as well.

Currently the app assumes all depth camera options present in the 13 Pro Max are available (dual, dual wide angle, wide angle with LiDAR, TruDepth), but this can easily be fixed.
As a temporary workaround to use on other phones, go to `object-capture-test/Views/CaptureView.swift` and comment out any device types you don't have. Also change the default type on line 15.

## Setup
1. Start [the companion API](https://github.com/sbwp/photogrammetry-api)
1. Open the project in Xcode
1. Click on the project name in the top bar in Xcode and choose "Edit Scheme..."
1. Choose the "Run" scheme, and then the "Arguments" tab
1. Under "Environment Variables", add the following 3 required environment variables:
    - `SVC_BASE_URL` - The IP the service is being hosted on, e.g. `192.168.4.44`.
    - `SVC_SCHEME` - Either `http` or `https` depending on whether you've set up HTTPS, e.g. `http`.
    - `SVC_PORT` - The port the service is being exposed as, e.g. `8080`.
1. Attach a compatible phone
1. Under Signing & Capabilities, change the team to yours and the bundle identifier to something under a domain you own
    - Not sure if there actually are any entitlements enabled that require registering but if you're going to change the code and possibly add such capabilities, please change it.
1. Build & Run

## Usage
Upon opening the app, you will see the standard Files app file picker. A new Object Capture Project file with the `.ocproj` extension should appear. Tap on this to open it.

### Capture Mode
You will be presented with a camera view. There is a capture button at the bottom of the screen to take a single photo. If you take a photo, you will see the number of photos increase in the top middle of the screen.

There is also a switch camera button that will switch between wide angle with LiDAR, wide angle dual lens (wide/ultra-wide), dual lens (wide/telephoto), and TruDepth (front-facing). You should be able to tell what mode you are in based on what appears on screen, other than LiDAR, which is indicated with the LiDAR indicator in the top left of the screen.
> Note that this feature is not yet fully implemented, so you will need to toggle between preview and capture mode to see the camera change

In the bottom left of the screen is the autocapture button, which will take a photo automatically every 1.5 seconds until the stop button is pressed.

For advice on capturing photos for photogrammetry, see [Apple's documentation](https://developer.apple.com/documentation/realitykit/capturing_photographs_for_realitykit_object_capture).

Finally, in the top right is the "Preview" button, which brings you to preview mode.

### Preview Mode
In preview mode, you can view all of the photos captured, or press the Edit button in the top right to delete or reorder photos using standard iOS list editing semantics.

The camera button at the top right of the screen allows you to return to capture mode to take additional photos.

### Processing photos
When you have your photogrammetry photos ready to upload, press the "Upload" button at the bottom of the screen. This will take a while, and the app must remain open <!-- TODO: allow backgrounding during processing and possibly upload --> as the following steps occur:

1. Uploading: Your photos are being uploaded to the backend for processing
2. Processing: Your photos are being processed to create a 3D model
3. Downloading: The processing is complete and the model is being downloaded to your phone
  
Once the process is complete, the 3D model will open automatically on your phone for viewing.

**WARNING:** The model is **NOT** saved automatically. Use the "Save" button in the top right corner to save the model to your phone's hard drive for later access via the Files app.

If the processing fails for any reason, a failure message will appear along with a retry button.
