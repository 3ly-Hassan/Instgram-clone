import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instgram/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/utils.dart';

class AudioScreen extends StatefulWidget {
  final String uId;
  final String photoUrl;
  final bool caller;
  const AudioScreen(
      {super.key,
      required this.uId,
      this.caller = false,
      required this.photoUrl});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  @override
  void initState() {
    print('=============init =================');
    // Set up an instance of Agora engine
    setupVideoSDKEngine();
    super.initState();
  }

  bool speakerOn = true;
  bool mute = false;
  int uid = 0; // uid of the local user
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  RtcEngine agoraEngine = createAgoraRtcEngine(); // Agora engine instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Get started with Audio Calling'),
        ),
        body: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: _isJoined
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(
                              context.read<UserProvider>().user!.photoUrl),
                          radius: 36,
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
            // Button Row
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                          backgroundColor:
                              speakerOn ? primaryColor : secondaryColor),
                      onPressed: () {
                        speakerOn = !speakerOn;
                        agoraEngine.setEnableSpeakerphone(speakerOn);
                        setState(() {});
                      },
                      child: speakerOn
                          ? const Icon(
                              CupertinoIcons.speaker_3_fill,
                              color: Colors.black,
                            )
                          : const Icon(
                              CupertinoIcons.speaker_3,
                              color: mobileBackgroundColor,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                          backgroundColor:
                              mute ? primaryColor : secondaryColor),
                      onPressed: () {
                        mute = !mute;
                        agoraEngine.muteLocalAudioStream(mute);
                        setState(() {});
                      },
                      child: mute
                          ? const Icon(
                              Icons.mic_off,
                              color: mobileBackgroundColor,
                            )
                          : const Icon(
                              Icons.mic,
                              color: mobileBackgroundColor,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                          backgroundColor: Colors.red),
                      onPressed: _isJoined ? () => {leave()} : null,
                      child: const Icon(
                        Icons.call_end,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Button Row ends
        ));
  }

// Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(
            uid: uid,
          ),
        ),
      );
      // return const Text(
      //   'Loadded',
      //   textAlign: TextAlign.center,
      // );
    } else {
      return const Text(
        'Loading.....',
        textAlign: TextAlign.center,
      );
    }
  }

// Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(widget.photoUrl),
        radius: 48,
      );
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for Your Friend';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone].request();
    print('================= after permision ===========');

    //create an instance of the Agora engine

    try {
      await agoraEngine.initialize(
          const RtcEngineContext(appId: 'a325d43f7b9642d8bc3308f0992491d7'));
      print('================= after initialization ===========');
    } catch (e) {
      print('================${e.toString()}================');
    }

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print(
              "=====================Local user uid:${connection.localUid} joined the channel");
          uid = connection.localUid!;

          _isJoined = true;

          setState(() {});
          if (widget.caller) {
            sendCall();
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print(
              "===================Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onLeaveChannel: (connection, stats) {
          if (connection.localUid == uid) {
            if (!widget.caller) {
              removeInCall();
            }
            leave();
            Navigator.of(context).pop();
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print(
              "====================Remote user uid:$remoteUid left the channel");
          // setState(() {
          //   _remoteUid = null;
          // });
          leave();
          Navigator.of(context).pop();
        },
      ),
    );
    await join();
  }

  void sendCall() async {
    print('=============send a call================');
    final temp = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uId)
        .get();
    if (temp.data()!['ring'] == null &&
        (temp.data()!['inCall'] == null || !temp.data()!['inCall'])) {
      FirebaseFirestore.instance.collection('users').doc(widget.uId).update({
        'ring': context.read<UserProvider>().user!.uid,
        'ringType': 'audio'
      });
    } else {
      showSnackBar(temp.data()!['username'] + ' is in a call', context);
    }
  }

  Future<void> join() async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    print('==================join==============');
    await agoraEngine.joinChannel(
      token:
          '007eJxTYFjI0f94w8mlD9+8fbFx6pbg8EnzNxd3ej9OeqxefNPd9vEhBYZEYyPTFBPjNPMkSzMToxSLpGRjYwOLNANLSyMTS8MUc5G1ZckNgYwMNYkejIwMEAjiszLk5+ZlJjIwAACN4yJs',
      channelId: 'omnia',
      options: options,
      uid: uid,
    );
    print('==================join-end==============');
  }

  void leave() {
    agoraEngine.leaveChannel();
  }

  @override
  void dispose() {
    leave();
    super.dispose();
  }

  void removeInCall() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uId)
        .update({'inCall': false});
  }
}
