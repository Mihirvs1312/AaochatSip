import 'dart:developer';

import 'package:callingproject/src/Databased/calllog_history.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';

import '../models/RefreshCallLogEvent.dart';
import '../models/call_model.dart';
import '../providers/layout_provider.dart';
import '../utils/Constants.dart';
import '../utils/secure_storage.dart';
import 'dialpad_widget.dart';

enum CallAction { accept, reject, switchTo, hangup, hold, redirect }

enum CdrAction { delete, deleteAll }

class LogListScreen extends StatefulWidget {
  const LogListScreen({super.key});

  @override
  State<LogListScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogListScreen> {
  EventTaxi eventBus = EventTaxiImpl.singleton();
  String currentMenu = 'call_logs';
  final ScrollController _scrollController = ScrollController();
  String mSip_usernam = "";
  String mExtentionNumber = "";

  static String mDuration = "";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    final calls = context.watch<AppCallsModel>();
    final mCardModel = context.watch<CdrsModel>();
    if (!calls.isEmpty) {
      provider.UpdateCallToLogList(context, mCardModel);
      // if (calls.callItems[0].state == CallState.proceeding) {
      // } else {
      //   provider.AddCallToLogList(context, calls.callItems, mCardModel);
      // }
    }
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        child: buildCdrsList(),
      ),
    );
  }

  ShowPreference() async {
    mSip_usernam = (await SecureStorage().read(Constants.SIP_USERNAME))!;
    mExtentionNumber =
        (await SecureStorage().read(Constants.EXTENSION_NUMBER))!;
  }

  @override
  void initState() {
    super.initState();
    eventBus.registerTo<RefreshCallLogEvent>(false).listen((event) {
      if (event.isUpdate) {
        Future.delayed(Duration(seconds: 2), () {
          /*TODO Api Calling*/
          /*Databased Update for Duration*/
          final provider = Provider.of<LayoutProvider>(context, listen: false);
          final mCardModel = context.read<CdrsModel>();
          mDuration = mCardModel[0].duration;
          provider.Updateduration(mDuration);
          log("Call_Update_Log:$mDuration");
        });
      }
    });
  }

  Widget buildCdrsList() {
    final provider = Provider.of<LayoutProvider>(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                changeCurrentMenu('call_logs');
              },
              child: Text(
                'Call Logs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      currentMenu == 'call_logs'
                          ? FontWeight.bold
                          : FontWeight.normal,
                  color:
                      currentMenu == 'call_logs' ? Colors.white : Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                changeCurrentMenu('voice_mails');
              },
              child: Text(
                'Voice Mails',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      currentMenu == 'voice_mails'
                          ? FontWeight.bold
                          : FontWeight.normal,
                  color:
                      currentMenu == 'voice_mails' ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        // Expanded(
        //   child: ListView.separated(
        //     scrollDirection: Axis.vertical,
        //     itemCount: cdrs.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       CdrModel cdr = cdrs[index];
        //       return ListTile(
        //         selected: (_selCdrRowIdx == index),
        //         selectedColor: Colors.black,
        //         selectedTileColor: Theme.of(context).secondaryHeaderColor,
        //         contentPadding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        //         leading: _getCdrIcon(cdr),
        //         title: _getCdrTitle(cdr),
        //         subtitle:
        //             (_selCdrRowIdx == index) ? _getCdrSubTitle(cdr) : null,
        //         trailing: _getCdrRowTrailing(cdr, index),
        //         dense: true,
        //         onTap: () {
        //           setState(() {
        //             context.read<AppAccountsModel>().setSelectedAccountByUri(
        //               cdr.accUri,
        //             );
        //             mCallProvider.phoneNumbCtrl.text = cdr.remoteExt;
        //             _selCdrRowIdx = index;
        //           });
        //         },
        //       );
        //     },
        //     separatorBuilder:
        //         (BuildContext context, int index) => const Divider(height: 0),
        //   ),
        // ),

        /*Todo Separate*/
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.mCallLogHistory.length,
            itemBuilder: (context, index) {
              final cdrs = provider.mCallLogHistory[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // if (callLogs[index].src == myExtensionNo)
                      //   Icon(Icons.call_made_sharp, color: Colors.grey),
                      //
                      // if (callLogs[index].dst == myExtensionNo ||
                      //     (callLogs[index].dst != myExtensionNo &&
                      //         callLogs[index].src != myExtensionNo))
                      //   Icon(Icons.call_received_sharp, color: Colors.grey),
                      if (cdrs.incoming != null)
                        cdrs.incoming!
                            ? cdrs.connected!
                                ? Icon(
                                  Icons.call_received_rounded,
                                  color: Colors.green,
                                )
                                : Icon(
                                  Icons.call_missed_rounded,
                                  color: Colors.red,
                                )
                            : cdrs.connected!
                            ? Icon(
                              Icons.call_made_rounded,
                              color: Colors.lightGreen,
                            )
                            : const Icon(
                              Icons.call_missed_outgoing_rounded,
                              color: Colors.orange,
                            ),

                      SizedBox(width: 10),
                      Container(
                        width: 90,

                        // child: Text(
                        //   callLogs[index].getFormattedCallStatus(myExtensionNo),
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     color: callLogs[index].getCallLogColor(),
                        //   ),
                        // ),
                        child: Text(
                          cdrs.displName!.isEmpty
                              ? cdrs.remoteExt!
                              : "${cdrs.displName} (${cdrs.remoteExt})",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        width: 110,
                        child: Text(
                          provider.getFormattedCallStatus(cdrs),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: provider.getCallLogColor(cdrs),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        spacing: 2,
                        children: [
                          Text(
                            cdrs.madeAtDate ?? '',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(1)
                                      : Colors.black.withOpacity(0.7),
                            ),
                          ),
                          if (cdrs.connected != null ? cdrs.connected! : false)
                            Text(
                              "Duration: ${cdrs.duration}",
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                              ),
                            ),
                          if (cdrs.statusCode != 0)
                            Text(
                              "Status code: ${cdrs.statusCode}",
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                              ),
                            ),
                          if (cdrs.hasVideo!)
                            const Icon(
                              Icons.videocam_outlined,
                              color: Colors.grey,
                              size: 18,
                            ),
                        ],
                      ),
                      SizedBox(width: 15),
                      // if (callLogs[index].src == mExtentionNumber)
                      //   InkWell(
                      //     onTap: () {
                      //       eventBus.fire(PlaceCallEvent(callLogs[index].dst));
                      //     },
                      //     child: Text(
                      //       Get.find<LayoutController>().getCallDestinationName(
                      //         callLogs[index],
                      //       ),
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   )
                      // else
                      //   InkWell(
                      //     onTap: () {
                      //       eventBus.fire(
                      //         PlaceCallEvent(
                      //           callLogs[index].src == myExtensionNo
                      //               ? callLogs[index].dst
                      //               : callLogs[index].src,
                      //         ),
                      //       );
                      //     },
                      //     child: Text(
                      //       '${callLogs[index].src} - ${callLogs[index].cnam}',
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      Spacer(),

                      // call button
                      // SizedBox(width: 10),
                      // if (callLogs[index].recordingfile != '')
                      //   Obx(
                      //     () => IconButton(
                      //       tooltip: 'Recording',
                      //       onPressed: () {
                      //         if (player.state == PlayerState.playing) {
                      //           player.stop();
                      //           isPlaying.value = false;
                      //           recordingFile.value = '';
                      //         } else {
                      //           player.play(
                      //             UrlSource(callLogs[index].getRecordingFile()),
                      //           );
                      //           player.getDuration();
                      //           isPlaying.value = true;
                      //           recordingFile.value =
                      //               callLogs[index].getRecordingFile();
                      //         }
                      //       },
                      //       icon: Icon(
                      //         isPlaying.value &&
                      //                 recordingFile.value ==
                      //                     callLogs[index].getRecordingFile()
                      //             ? Icons.stop
                      //             : Icons.play_arrow,
                      //       ),
                      //     ),
                      //   ),
                      SizedBox(width: 10),
                      _getCdrRowTrailing(cdrs, index, provider),
                      // create ticket button
                      // if (callLogs[index].supportTicketMaster ==
                      //     null)
                      //   ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.grey.shade900,
                      //       foregroundColor:
                      //       Colors.white.withOpacity(0.5),
                      //     ),
                      //     onPressed: () {
                      //       Get.find<LayoutController>()
                      //           .goToCreateSupportTicket(
                      //           callLogs[index].uniqueid);
                      //     },
                      //     child: Text('Create Ticket'),
                      //   ),
                      // if (callLogs[index].supportTicketMaster !=
                      //     null)
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.green,
                      //     foregroundColor: Colors.black,
                      //   ),
                      //   onPressed: () {
                      //     Get.dialog(
                      //       SupportTicketDetailModal(
                      //         supportTicketMaster: callLogs[index]
                      //             .supportTicketMaster!,
                      //       ),
                      //     );
                      //   },
                      //   child: Text(
                      //       '#${callLogs[index].supportTicketMaster?.ticket_id}'),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  changeCurrentMenu(menuwe) {
    currentMenu = menuwe;
    if (menuwe == 'call_logs') {
    } else {
      // getVoiceMails();
    }
  }

  Icon _getCdrIcon(CdrModel cdr) {
    if (cdr.incoming) {
      return cdr.connected
          ? const Icon(Icons.call_received_rounded, color: Colors.green)
          : const Icon(Icons.call_missed_rounded, color: Colors.red);
    } else {
      return cdr.connected
          ? const Icon(Icons.call_made_rounded, color: Colors.lightGreen)
          : const Icon(
            Icons.call_missed_outgoing_rounded,
            color: Colors.orange,
          );
    }
  }

  Widget _getCdrTitle(CdrModel cdr) {
    return Text(
      cdr.displName.isEmpty
          ? cdr.remoteExt
          : "${cdr.displName} (${cdr.remoteExt})",
      style: Theme.of(context).textTheme.titleSmall,
    );
  }

  Widget? _getCdrSubTitle(CdrModel cdr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          cdr.accUri,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        Wrap(
          spacing: 5,
          children: [
            Text(
              cdr.madeAtDate,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            if (cdr.connected) Text("Duration: ${cdr.duration}"),
            if (cdr.statusCode != 0) Text("Status code: ${cdr.statusCode}"),
            if (cdr.hasVideo)
              const Icon(Icons.videocam_outlined, color: Colors.grey, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _getCdrRowTrailing(
    CallLogHistory cdr,
    int index,
    LayoutProvider provider,
  ) {
    return PopupMenuButton<CdrAction>(
      onSelected: (CdrAction action) {
        // for (var i = 0; i < provider.mCallLogHistory.length; i++) {
        // }
        // _onCdrMenuAction(action, index);
        provider.deleteCallLog(cdr);
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<CdrAction>>[
            const PopupMenuItem<CdrAction>(
              value: CdrAction.delete,
              child: Wrap(
                spacing: 5,
                children: [Icon(Icons.delete), Text("Delete")],
              ),
            ),
          ],
    );
  }

  void _onCdrMenuAction(CdrAction action, int index) {
    context.read<CdrsModel>().remove(index);
  }
}
