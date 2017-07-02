# WallAppiOS

Front end for TSL Hiring assignment

Download the repository
```
git clone https://github.com/mddrill/WallAppiOS/
```

Open `WallAppiOS.xcworkspace` in Xcode and press `CMD+U` to run the unit and UI tests.

To run the app, you must first run `WallAppBackend` on localhost. Assuming you have `WallAppBackend` in your home directory and have followed the instruction in https://github.com/mddrill/WallAppBackend/blob/master/README.md run:
```
cd ~/WallAppBackend
source venv/bin/activate
python manage.py runsslserver
```

You can now run the app in the iOS simulator with `CMD+R`.
