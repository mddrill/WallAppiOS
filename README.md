# WallAppiOS

Front end for TSL Hiring assignment

Uses 
iOS 10
Swift 3
Almofire
MockingJay
Quick
Nimble

Download the repository
```
git clone https://github.com/mddrill/WallAppiOS/
```

Open `WallAppiOS.xcworkspace` in Xcode and press `CMD+U` to run the unit and UI tests. The UI tests will take about 10 minutes to run. Be sure that you have the hardware keyboard disabled in iOS simulator or the UI tests will fail.

To run the app, you must first run `WallAppBackend` on localhost. Assuming you have `WallAppBackend` in your home directory and have followed the instruction in https://github.com/mddrill/WallAppBackend/blob/master/README.md run:
```
cd ~/WallAppBackend
source venv/bin/activate
python manage.py runsslserver
```

You can now run the app in the iOS simulator with `CMD+R`.
