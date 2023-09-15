import 'package:quote/model/quote.dart';

class search {
  Info? iInfo;
  int? count;
  int? totalCount;
  int? page;
  int? totalPages;
  List<Results>? results;

  search(
      {this.iInfo,
      this.count,
      this.totalCount,
      this.page,
      this.totalPages,
      this.results});

  search.fromJson(Map<String, dynamic> json) {
    iInfo =
        json['__info__'] != null ?  Info.fromJson(json['__info__']) : null;
    count = json['count'];
    totalCount = json['totalCount'];
    page = json['page'];
    totalPages = json['totalPages'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (iInfo != null) {
      data['__info__'] = iInfo!.toJson();
    }
    data['count'] = count;
    data['totalCount'] = totalCount;
    data['page'] = page;
    data['totalPages'] = totalPages;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Info {
  Search? search;

  Info({this.search});

  Info.fromJson(Map<String, dynamic> json) {
    search = json['$search'] != null ? Search.fromJson(json['$search']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (search != null) {
      data['$search'] = search!.toJson();
    }
    return data;
  }
}

class Search {
  QueryString? queryString;

  Search({this.queryString});

  Search.fromJson(Map<String, dynamic> json) {
    queryString = json['queryString'] != null
        ? QueryString.fromJson(json['queryString'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (queryString != null) {
      data['queryString'] = queryString!.toJson();
    }
    return data;
  }
}

class QueryString {
  String? query;
  String? defaultPath;

  QueryString({this.query, this.defaultPath});

  QueryString.fromJson(Map<String, dynamic> json) {
    query = json['query'];
    defaultPath = json['defaultPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['query'] = query;
    data['defaultPath'] = defaultPath;
    return data;
  }
}
