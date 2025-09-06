import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:new_applicatoon_demo/common/colors.dart';
import 'package:new_applicatoon_demo/common/common.dart';
import 'package:new_applicatoon_demo/common/widgets/no_connectivity.dart';
import 'package:new_applicatoon_demo/models/listdata_model.dart';
import 'package:new_applicatoon_demo/models/news_model.dart' as m;
import 'package:new_applicatoon_demo/providers/news_provider.dart';
import 'package:new_applicatoon_demo/screens/home/widgets/CategoryItem.dart';
import 'package:new_applicatoon_demo/screens/home/widgets/newsCard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology'
  ];

  int activeCategory = 0;

  int page = 1;
  bool isFinish = false;
  bool data = false;
  List<m.News> articles = [];

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    if (await getInternetStatus()) {
      getNewsData();
    } else {
      Navigator.of(context, rootNavigator: true,)
          .push(
            MaterialPageRoute(
              builder: (context) => const NoConnectivity(),
            ),
          )
          .then(
            (value) => checkConnectivity(),
          );
    }
  }

  Future<bool> getNewsData() async {
    ListData listData = await NewsProvider()
        .GetEverything(categories[activeCategory].toString(), page++);

    if (listData.status) {
      List<m.News> items = listData.data as List<m.News>;
      data = true;

      if (mounted) {
        setState(() {});
      }

      if (items.length == listData.totalContent) {
        isFinish = true;
      }

      if (items.isNotEmpty) {
        articles.addAll(items);
        setState(() {});
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
            ),
            child: Text(
              "News Section",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.black,
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                size: 34,
                color: AppColors.white,
              ),
              onPressed: () async {
                String? query = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController();
                    return AlertDialog(
                      title: const Text('Search News'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter keyword',
                        ),
                        onSubmitted: (value) => Navigator.of(context).pop(value),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(controller.text),
                          child: const Text('Search'),
                        ),
                      ],
                    );
                  },
                );
                if (query != null && query.trim().isNotEmpty) {
                  setState(() {
                    articles = [];
                    page = 1;
                    isFinish = false;
                    data = false;
                  });
                  // Fetch news for the search query
                  ListData listData = await NewsProvider().GetEverything(query.trim(), page++);
                  if (listData.status) {
                    List<m.News> items = listData.data as List<m.News>;
                    setState(() {
                      articles.addAll(items);
                      data = true;
                      if (items.length == listData.totalContent) {
                        isFinish = true;
                      }
                    });
                  }
                }
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: size.width,
              child: ListView.builder(
                itemCount: categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) => CategoryItem(
                  index: index,
                  categoryName: categories[index],
                  activeCategory: activeCategory,
                  onClick: () {
                    setState(() {
                      activeCategory = index;
                      articles = [];
                      page = 1;
                      isFinish = false;
                      data = false;
                    });
                    getNewsData();
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: size.height,
              child: LoadMore(
                isFinish: isFinish,
                onLoadMore: getNewsData,
                whenEmptyLoad: true,
                delegate: const DefaultLoadMoreDelegate(),
                textBuilder: DefaultLoadMoreTextBuilder.english,
                child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) =>
                      NewsCard(article: articles[index]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
