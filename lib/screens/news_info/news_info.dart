import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:new_applicatoon_demo/common/colors.dart';
import 'package:new_applicatoon_demo/models/news_model.dart';
import 'package:new_applicatoon_demo/services/LocalNewsInteractionService.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsInfo extends StatefulWidget {
  final News news;

  const NewsInfo({
    super.key,
    required this.news,
  });

  @override
  State<NewsInfo> createState() => _NewsInfoState();
}

class _NewsInfoState extends State<NewsInfo> {
  final LocalNewsInteractionService _interactionService = LocalNewsInteractionService();
  final TextEditingController _commentController = TextEditingController();
  bool _showWebView = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String link = widget.news.url ?? widget.news.title ?? ""; // Use unique identifier for news
    bool isLiked = _interactionService.isLiked(link);
    List<String> comments = _interactionService.getComments(link);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: GestureDetector(
          onTap: () {
            if (_showWebView) {
              setState(() {
                _showWebView = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
          child: const Icon(
            Icons.arrow_back_sharp,
            color: AppColors.white,
          ),
        ),
      ),
      body: _showWebView
          ? SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.parse(widget.news.url ?? "")),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  // Fix: Only show image if urlToImage is not null/empty, else show placeholder
                  if (widget.news.urlToImage != null &&
                      widget.news.urlToImage!.isNotEmpty)
                    Image.network(
                      widget.news.urlToImage!,
                      fit: BoxFit.contain,
                      width: size.width,
                      frameBuilder: (BuildContext context, Widget child, int? frame,
                          bool wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        if (frame == null) {
                          return Center(
                            child: Skeleton(
                              isLoading: true,
                              skeleton: SkeletonParagraph(),
                              child: const Text(''),
                            ),
                          );
                        }
                        return child;
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: size.width,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      width: size.width,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 8,
                      right: 8,
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.news.title.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: AppColors.black,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: size.width / 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.news.author.toString(),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: AppColors.black,
                                  size: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Text(
                                    Jiffy.parse(
                                      widget.news.publishedAt.toString(),
                                    ).fromNow().toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          widget.news.content.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add Like and Comment UI
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _interactionService.toggleLike(link);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(isLiked ? "Liked" : "Like"),
                        const SizedBox(width: 24),
                        Icon(Icons.comment, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('${comments.length} Comments'),
                      ],
                    ),
                  ),
                  // Comment input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: "Add a comment...",
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_commentController.text.trim().isNotEmpty) {
                              setState(() {
                                _interactionService.addComment(link, _commentController.text.trim());
                                _commentController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Display comments
                  if (comments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Comments:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...comments.map((c) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text("- $c"),
                          )),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 50,
                  ),
                  // Replace "View full article" with "Read full article here" button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showWebView = true;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Read full article here",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.chrome_reader_mode,
                          color: AppColors.black,
                          size: 16,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.facebook,
                          size: 26,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.email_outlined,
                          size: 26,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.wechat_sharp,
                          size: 26,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
