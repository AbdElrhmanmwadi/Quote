// ignore_for_file: prefer_collection_literals

class Quote {
  int? count;
  int? totalCount;
  int? page;
  int? totalPages;
  int? lastItemIndex;
  List<Results>? results;

  Quote(
      {this.count,
      this.totalCount,
      this.page,
      this.totalPages,
      this.lastItemIndex,
      this.results});

  Quote.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    totalCount = json['totalCount'];
    page = json['page'];
    totalPages = json['totalPages'];
    lastItemIndex = json['lastItemIndex'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add( Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['count'] = count;
    data['totalCount'] = totalCount;
    data['page'] = page;
    data['totalPages'] = totalPages;
    data['lastItemIndex'] = lastItemIndex;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? sId;
  String? author;
  String? content;
  List<String>? tags;
  String? authorSlug;
  int? length;
  String? dateAdded;
  String? dateModified;

  Results(
      {this.sId,
      this.author,
      this.content,
      this.tags,
      this.authorSlug,
      this.length,
      this.dateAdded,
      this.dateModified});

  Results.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    author = json['author'];
    content = json['content'];
    tags = json['tags'].cast<String>();
    authorSlug = json['authorSlug'];
    length = json['length'];
    dateAdded = json['dateAdded'];
    dateModified = json['dateModified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['author'] = author;
    data['content'] = content;
    data['tags'] = tags;
    data['authorSlug'] = authorSlug;
    data['length'] = length;
    data['dateAdded'] = dateAdded;
    data['dateModified'] = dateModified;
    return data;
  }
}
