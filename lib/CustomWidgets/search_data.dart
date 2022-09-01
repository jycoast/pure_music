// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
//
// import '../Screens/Common/song_list.dart';
// import '../Screens/Player/audioplayer.dart';
// import 'copy_clipboard.dart';
// import 'download_button.dart';
// import 'like_button.dart';
//
// class SearchData extends StatefulWidget {
//   const SearchData({Key? key}) : super(key: key);
//
//   @override
//   State<SearchData> createState() => _SearchDataState();
// }
//
// class _SearchDataState extends State<SearchData> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: sortedKeys.map(
//         (e) {
//           final String key = position[e].toString();
//           final List? value = searchedData[key] as List?;
//           if (value == null) {
//             return const SizedBox();
//           }
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 25, top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       key,
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.secondary,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     if (key != 'Top Result')
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 if (key == 'Albums' || key == 'Playlists' || key == 'Artists') {
//                                   // Navigator.push(
//                                   //   context,
//                                   //   PageRouteBuilder(
//                                   //     opaque:
//                                   //         false,
//                                   //     pageBuilder: (
//                                   //       _,
//                                   //       __,
//                                   //       ___,
//                                   //     ) =>
//                                   //         AlbumSearchPage(
//                                   //       query: query ==
//                                   //               ''
//                                   //           ? widget
//                                   //               .query
//                                   //           : query,
//                                   //       type: key,
//                                   //     ),
//                                   //   ),
//                                   // );
//                                 }
//                                 if (key == 'Songs') {
//                                   Navigator.push(
//                                     context,
//                                     PageRouteBuilder(
//                                       opaque: false,
//                                       pageBuilder: (_, __, ___,) => SongsListPage(
//                                         listItem: {
//                                           'id': query == ''? widget.query : query,
//                                           'title': key,
//                                           'type': 'songs',
//                                         },
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     AppLocalizations.of(
//                                       context,
//                                     )!
//                                         .viewAll,
//                                     style: TextStyle(
//                                       color: Theme.of(
//                                         context,
//                                       ).textTheme.caption!.color,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                   Icon(
//                                     Icons.chevron_right_rounded,
//                                     color: Theme.of(
//                                       context,
//                                     ).textTheme.caption!.color,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               ListView.builder(
//                 itemCount: value.length,
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 padding: const EdgeInsets.only(
//                   left: 5,
//                   right: 10,
//                 ),
//                 itemBuilder: (context, index) {
//                   final int count = value[index]['count'] as int? ?? 0;
//                   String countText = value[index]['artist'].toString();
//                   count > 1
//                       ? countText =
//                           '$count ${AppLocalizations.of(context)!.songs}'
//                       : countText =
//                           '$count ${AppLocalizations.of(context)!.song}';
//                   return ListTile(
//                     contentPadding: const EdgeInsets.only(
//                       left: 15.0,
//                     ),
//                     title: Text(
//                       '${value[index]["title"]}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w500,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     subtitle: Text(
//                       key == 'Albums' ||
//                               (key == 'Top Result' &&
//                                   value[0]['type'] == 'album')
//                           ? '$countText\n${value[index]["subtitle"]}'
//                           : '${value[index]["subtitle"]}',
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     isThreeLine: key == 'Albums' ||
//                         (key == 'Top Result' && value[0]['type'] == 'album'),
//                     leading: Card(
//                       elevation: 8,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           key == 'Artists' ||
//                                   (key == 'Top Result' &&
//                                       value[0]['type'] == 'artist')
//                               ? 50.0
//                               : 7.0,
//                         ),
//                       ),
//                       clipBehavior: Clip.antiAlias,
//                       child: CachedNetworkImage(
//                         fit: BoxFit.cover,
//                         errorWidget: (context, _, __) => Image(
//                           fit: BoxFit.cover,
//                           image: AssetImage(
//                             key == 'Artists' ||
//                                     (key == 'Top Result' &&
//                                         value[0]['type'] == 'artist')
//                                 ? 'assets/artist.png'
//                                 : key == 'Songs'
//                                     ? 'assets/cover.jpg'
//                                     : 'assets/album.png',
//                           ),
//                         ),
//                         imageUrl:
//                             '${value[index]["image"].replaceAll('http:', 'https:')}',
//                         placeholder: (context, url) => Image(
//                           fit: BoxFit.cover,
//                           image: AssetImage(
//                             key == 'Artists' ||
//                                     (key == 'Top Result' &&
//                                         value[0]['type'] == 'artist')
//                                 ? 'assets/artist.png'
//                                 : key == 'Songs'
//                                     ? 'assets/cover.jpg'
//                                     : 'assets/album.png',
//                           ),
//                         ),
//                       ),
//                     ),
//                     trailing: key != 'Albums'
//                         ? key == 'Songs'
//                             ? Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   DownloadButton(
//                                     data: value[index] as Map,
//                                     icon: 'download',
//                                   ),
//                                   LikeButton(
//                                     mediaItem: null,
//                                     data: value[index] as Map,
//                                   ),
//                                   // TODO
//                                   // SongTileTrailingMenu(
//                                   //   data: value[
//                                   //           index]
//                                   //       as Map,
//                                   // ),
//                                 ],
//                               )
//                             : null
//                         : AlbumDownloadButton(
//                             albumName: value[index]['title'].toString(),
//                             albumId: value[index]['id'].toString(),
//                           ),
//                     onLongPress: () {
//                       copyToClipboard(
//                         context: context,
//                         text: '${value[index]["title"]}',
//                       );
//                     },
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         PageRouteBuilder(
//                           opaque: false,
//                           pageBuilder: (_, __, ___,) =>
//                               key == 'Artists' ||
//                                       (key == 'Top Result' &&
//                                           value[0]['type'] == 'artist')
//                                   ? ArtistSearchPage(
//                                       data: value[index] as Map,
//                                     )
//                                   : key == 'Songs'
//                                       ? PlayScreen(
//                                           songsList: [value[index]],
//                                           index: 0,
//                                           offline: false,
//                                           fromMiniplayer: false,
//                                           fromDownloads: false,
//                                           recommend: true,
//                                         )
//                                       : SongsListPage(
//                                           listItem: value[index] as Map,
//                                         ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       ).toList(),
//     );
//   }
// }
