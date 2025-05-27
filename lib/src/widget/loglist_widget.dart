import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';

import '../models/RefreshCallLogEvent.dart';
import '../models/appacount_model.dart';
import '../models/call_model.dart';
import '../providers/call_logs_provider.dart';
import 'dialpad_widget.dart';

enum CallAction { accept, reject, switchTo, hangup, hold, redirect }

class LogListScreen extends StatefulWidget {
  const LogListScreen({super.key});

  @override
  State<LogListScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogListScreen> {
  EventTaxi eventBus = EventTaxiImpl.singleton();
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Expanded(child: buildCdrsList()));
  }

  @override
  void initState() {
    super.initState();
    eventBus.registerTo<RefreshCallLogEvent>(false).listen((event) {
      Future.delayed(Duration(seconds: 2), () {
        /*TODO Api Calling*/
        // updateLatestCallLog();
      });
    });
  }

  Widget buildCdrsList() {
    final cdrs = context.watch<CdrsModel>();
    int _selCdrRowIdx = 0;
    final mCallProvider = Provider.of<CallProvider>(context);

    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: cdrs.length,
      itemBuilder: (BuildContext context, int index) {
        CdrModel cdr = cdrs[index];
        return ListTile(
          selected: (_selCdrRowIdx == index),
          selectedColor: Colors.black,
          selectedTileColor: Theme.of(context).secondaryHeaderColor,
          //contentPadding:const EdgeInsets.fromLTRB(0, 0, 10, 0),
          leading: _getCdrIcon(cdr),
          title: _getCdrTitle(cdr),
          subtitle: (_selCdrRowIdx == index) ? _getCdrSubTitle(cdr) : null,
          trailing: _getCdrRowTrailing(cdr, index),
          dense: true,
          onTap: () {
            setState(() {
              context.read<AppAccountsModel>().setSelectedAccountByUri(
                cdr.accUri,
              );
              mCallProvider.phoneNumbCtrl.text = cdr.remoteExt;
              _selCdrRowIdx = index;
            });
          },
        );
      },
      separatorBuilder:
          (BuildContext context, int index) => const Divider(height: 0),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cdr.accUri,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        Wrap(
          spacing: 5,
          children: [
            Text(cdr.madeAtDate),
            if (cdr.connected) Text("Duration: ${cdr.duration}"),
            if (cdr.statusCode != 0) Text("Status code: ${cdr.statusCode}"),
            if (cdr.hasVideo)
              const Icon(Icons.videocam_outlined, color: Colors.grey, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _getCdrRowTrailing(CdrModel cdr, int index) {
    return PopupMenuButton<CdrAction>(
      onSelected: (CdrAction action) {
        _onCdrMenuAction(action, index);
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
