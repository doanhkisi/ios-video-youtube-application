# Video YT
This is the best iOS youtube player implement in Swift program language. It's can play and download unlimited video from Youtube.
You can watch live app at: https://itunes.apple.com/us/app/apple-store/id1086349582?pt=118052683&ct=iosdevgroup&mt=8

## Features:

* Top trends video
* List playlist
* Watch video without youtube ads
* Download video with many quality options
* Search video, playlist, channel
* Save favorites
* Save histories
* Create offline playlist video

## Screenshot

![youtube-player](http://a3.mzstatic.com/us/r30/Purple69/v4/cb/cd/a3/cbcda391-dc6c-f5f7-a16f-d19c3a71f438/screen322x572.jpeg)
![youtube-player](http://a1.mzstatic.com/us/r30/Purple69/v4/a3/4e/6f/a34e6f37-bb6d-ae84-5ee8-c83f10c94a04/screen322x572.jpeg)

## How to build & requirements
* Xcode 7.3.1
* Pods newset version
* iOS 8.0 above

Create Youtube API Key:
Visit https://console.developers.google.com/apis/credentials/key?type=CLIENT_SIDE_IOS&project=<Your_Google_Project>

Change Youtube API Key on TubeTrends.swift file at line 111
```
static var secretKeyApi: [String] {
            let keyArray = ["xxx------Your_YOUTUBE_API_Key---------xxx"]
            return keyArray
        }
```
Go to your project root directiory:
```
pod install --verbose
```
Open TubeTrends.xcworkspace in Xcode then you can build project normaly.

## Donate

Give me a coffee cup if it's useful.

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NHAFTJD9A6EVS)

## Licence

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
