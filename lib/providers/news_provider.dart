import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_applicatoon_demo/common/colors.dart';
import 'package:new_applicatoon_demo/models/listdata_model.dart';
import 'package:new_applicatoon_demo/models/news_model.dart';
import 'package:new_applicatoon_demo/services/Api.dart';

class NewsProvider {
  Future<ListData> GetEverything(String keyword, int page) async {
    ListData articles = ListData([], 0, false);
    await ApiService().getEverything(keyword, page).then((response) {
      if (response.statusCode == 200) {
        Iterable data = jsonDecode(response.body)['articles'];
        articles = ListData(
          data.map((e) => News.fromJson(e)).toList(),
          jsonDecode(response.body)['totalArticles'],
          true,
        );
      } else {
        Fluttertoast.showToast(
          msg: jsonDecode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.lighterGray,
          textColor: AppColors.black,
          fontSize: 16.0,
        );
        throw Exception(response.statusCode);
      }
    });
    return articles;
  }
}
