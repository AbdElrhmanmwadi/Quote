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
        json['__info__'] != null ? new Info.fromJson(json['__info__']) : null;
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
    if (this.iInfo != null) {
      data['__info__'] = this.iInfo!.toJson();
    }
    data['count'] = this.count;
    data['totalCount'] = this.totalCount;
    data['page'] = this.page;
    data['totalPages'] = this.totalPages;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Info {
  Search? search;

  Info({this.search});

  Info.fromJson(Map<String, dynamic> json) {
    search =
        json['$search'] != null ? new Search.fromJson(json['$search']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.search != null) {
      data['$search'] = this.search!.toJson();
    }
    return data;
  }
}

class Search {
  QueryString? queryString;

  Search({this.queryString});

  Search.fromJson(Map<String, dynamic> json) {
    queryString = json['queryString'] != null
        ? new QueryString.fromJson(json['queryString'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.queryString != null) {
      data['queryString'] = this.queryString!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['query'] = this.query;
    data['defaultPath'] = this.defaultPath;
    return data;
  }
}


