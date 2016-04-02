# Custom Recommendation of videos and shows

## Problem

Personalized recommendation of videos based on the user's viewing history and video metadata. The recommendation is to filter a set of items most relevant to a user.

There are two files inside `data/` with the following information:

- videos.csv: Contains one row for each video, with the following columns:
  - Video_id: Video Id
  - Programa_id: Show Id
  - Programa_titulo: Show Title
  - Programa_descricao: Show Description
  - Category: Video Category
  - Title: Video title
  - Description: Video description
  - Tags: Tags separated by ";"

- video_views.csv: Contains one row for each pair of user/video, with the following columns:
  - Usuario_id: User Id
  - Video_id: Video Id
  - Porcentagem_vista: Video percentage seen by the user. Value is cumulative and can be larger if a user has viewed the video more than once.
  - Ultima_visualizacao: Timestamp of the last time the user saw the video

## Initial Exploration

File [data-exploration.md](data-exploration/data-exploration.md) describes the initial operation performed in the raw data. It was the first step of the process made in order to understand how it is distributed and to find clues about which paths to take.

Some conclusions drawn from this initial exploration were about the ratio between users and videos, the amount of video viewed by the majority of users and the diversity in the number of people who watched each video.

## Personalized Collaborative Filtering

It is based on recommendations of products that the person will probably like based on what similar people like. They are guided by the way the users interact with the system as well as their preferences.

### Search-based Collaborative Recommendations

The proposal is mainly based on Collaborative Filtering algorithms provided by Apache Mahout, in order to train and create a model of recommendations, coupled with the search technology of ElasticSearch to deploy the recommendations.

Points that underlie the approach [[1]]:

* The user behavior is the best clue to what they want;
* Co-occurrence is what allows the Apache Mahout to calculate important indicators of what should be recommended;
* There are similarities between the weighting of the scores of indicators in these models and mathematics that underlies text retrieval engines (like ElasticSearch);
* This mathematical similarity is what allows you to explore text-based search to deploy a recommender as Mahout + ElasticSearch.

### User-based vs. Item-based Collaborative Filtering

*User-based CF* finds users with similar preferences to the target user, and then adds the information to try to predict the preference of the target user for a given item.
The approach *Item-based CF* finds for each item some similar items, according to the preference of users in relation to it.

User-based algorithms need to perform much of the processing at request time since relationships between users can rapidly change, and this can result in increased system response time. The item-based approach has been chosen by a number of factors: can pre-compute and store the similarities some time in advance, so it is more suitable for real-time recommendations. Furthermore, the quantity of items tends to grow at a slower rate than users, also being more suitable in a scenario like the present: when the number of items is lower than the number of users.

Users preference about videos and shows will be * implied * since we have only a percentage of each video that was seen.

## System Architecture

The architecture was inspired by the diagram below (Source: [PracticalMachineLearning.pdf]):

![System architecture](readme/architecture.png)

Some changes in the *flow* were possible using the Apache Pig:

1. As new videos are created and information (such as meta-data) are edited, a script is to perform the necessary data processing and index them into ElasticSearch;
2. Within predefined time windows, the model can be trained based on new interaction logs of users-videos;
    3. The logs are processed according to the need (business rules might be applied);
    4. Users and items IDs are mapped to integers using a "dictionary";
    5. Mahout runs the model against the data, looking for similarities between items that serve as indicators for recommendation;
    6. ID's are translated to their original values;
    7. Indicators found by the model are indexed into ElasticSearch.

> Mahout accepts only ID's as whole for performance issues ([Source](https://mahout.apache.org/users/recommender/intro-als-hadoop.html)).

### Deploying recommendations to the user (Search-based recommendations)

Searches using the preferences of a user against the *indicators* of other videos will return recommendations in the form of lists of new videos (or shows) ordered by relevance, according to the user's taste.

This way you can customize the recommendations at query time, using information about the user **context** (such as the category being seen or geo-location).

![Deploy](readme/recommendations_deploy.png)

Using a search engine to deliver contextual recommendation, based on pre-computed similarities can also be seen as follows:

* Offline Machine Learning: intensive processing is performed "offline" (might be every night).
* Online recommendations: ElasticSearch quick response provides real-time recommendations, customized by context or recent history of a user.

### Stack of technologies used

[![Spark](readme/spark.png)](https://spark.apache.org/)
[![Hadoop](readme/hadoop.jpg)](https://hadoop.apache.org/)
[![Pig](readme/pig.gif)](https://pig.apache.org/)
[![Mahout](readme/mahout.png)](http://mahout.apache.org/)
[![ElasticSearch](readme/elastic.png)](https://www.elastic.co/)

([Reference](http://occamsmachete.com/ml/2014/10/07/creating-a-unified-recommender-with-mahout-and-a-search-engine/))

### Collaborative Filtering with Mahout

It is an open-source recommendations platform, which has now an active community and can be applied to problems like collaborative filtering, clustering and classification. Allows the recommendations to be assessed based on Root Mean Squared Error (RMSE) and Mean Absolute Error (MAE), as well as metrics like precision, recall and fallout.

Mahout similarity algorithms look for co-occurrences as clues for recommendation, but to avoid the so-called *supermarket paradox* [[3]] and that recommendations are not dominated by highly popular items, only "interesting" relationships are identified. Highly popular items are less interesting in this sense, when many people show preference for a particular item it is disregarded in the recommendations.

Running with Spark, Mahout has the power to **compute documents in parallel**, in a distributed manner inside a cluster, without losing the flexibility of running *standalone* (in a single virtual machine).

### Spark

Mahout has once been a machine learning library exclusively for Hadoop, but that has changed. New engines for parallel processing, such as *Spark*, are gaining prominence to the point of a project like Mahout suffer a recent change of course, supporting now also *Spark* [[2]].

It is an open-source engine for large-scale data processing in a quickly and distributed way. It is somehow a "polyglot" solution, since applications can be developed in Java, Scala or Python, and access data in HDFS, Cassandra, HBase and S3.

### Pig

Pig Latin was used to create the *data flow*, since reading the logs, through the application of possible business rules, until the indexing into ElasticSearch (through [es-hadoop](https://www.elastic.co/downloads/hadoop)).

It was the chosen because of it's ability to read, analyze and process large volumes of data in a distributed way.

### ElasticSearch

It is a open-source mechanism of search based on [Lucene](https://lucene.apache.org/core/). It stores documents composed of fields, each with name and content, which are indexed and can be found through searches done by such fields.

Together with the video metadata (and shows) indicators computed by Mahout's algorithms will be indexed. Mechanisms like ElasticSearch are optimized to perform this type of searches, so it will be used to find recommendations according to user's history [[4]].

Queries made to the ElasticSearch make it simple to add filters, such as **business rules**. Videos already seen by the user will be delited from recommendations delivered by EL, since a high level of *novelty* is desired.

When compared to other popular options (such as [Apache Solr](http://lucene.apache.org/solr/)), the ElasticSearch stands out mainly because it was developed as a **distributed processing** engine from the beginning. When run on a cluster, new *nodes* can be added and deleted according to the need.

#### Dithering

Full-text search engines like ElasticSearch order documents by relevance. It allows us to add variation to the results of a query through [some functions](http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-function-score-query.html).

Intentionally adding low relevance items within the list of recommendations is a technique called **dithering**, which aims to maintain the system data renewed. Since recommendation systems collects their own data (Machine Learning), without gimmicks like this tomorrow's data will be the same as today's, and it will not make new discoveries.

It is a technique that slightly impairs the recommender performance today to develop knowledge about users and thus improve over time.
([Source] (https://www.mapr.com/products/mapr-sandbox-hadoop/tutorials/recommender-tutorial))

### Scripts

Some scripts were necessary for the initial setup of the documents in ElasticSearch, and are therefore run once. Others are part of the flow described in system architecture, comprising the steps necessary for the training of new models and re-indexing ElasticSearch.

Description of the main actions:

#### Initial setup of EL index

* [users_index.R](scripts/data-preparation/users_index.R): based on files in `data /`, create a CSV with meta-data about users: history of seen videos and shows.
* [index_users_meta.pig](scripts/meta-data-index/index_users_meta.pig): indexes into El the CSV produced with meta-data about users.
* [index_show_meta.pig](scripts/meta-data-index/index_show_meta.pig): creates a collection of documents called 'shows` in EL with titles and descriptions of shows.
* [index_video_meta.pig](scripts/meta-data-index/index_video_meta.pig): creates a collection called `videos` in EL with videos meta-data.

> The task performed by `index_users_meta.pig`, to index the history of users, wouldn't exist in an ideal setting where this information probably would come from a database.

#### Training models

The script [train.sh](scripts/train.sh) automates model training process based on new data and re-indexes search engine. The tasks performed by it are documented in the code.

## Choice of algorithms

Apache Mahout allows us to test multiple algorithms, all seek to identify similarities between users and items but with different approaches. The file [mahout-evaluation.md](mahout-evaluation/mahout-evaluation.md) first shows how were designed and obtained the datasets used in the assessments, and finally exposes the results, justifying the choices made.

## Using the system

The proposed architecture can be implemented in a distributed manner, as mentioned above, but is flexible to the point of running on a single virtual machine. The operating system used was [Ubuntu 14.04.2 LTS](http://www.ubuntu.com/about/about-ubuntu), open-source as other software that make up the stack.

> All the following scripts must be run from the project root.

In the script `install.sh` are defined the system dependencies. It was used to create the environment and is useful for replicating it.

### Installing the software

Having cloned this repository, run:

> `./scripts/install.sh`

This command will automate the download and installation of a number of software used in the system.

### Indexing metadata

The metadata related to users, videos and shows should be indexed in ElasticSearch. It is a process executed *once*:

> `./scripts/setup.s`

### Creating recommendations

To train the model and index the indicators, run:

> `./scripts/train.sh`

When the process is completed, ElasticSearch will have indexed the indicators that form the basis for all recommendations. Whenever `train.sh` is used, **new data present in the CSV file will be used by the algorithms**.

### Recommendations in practice!

To access the web application at [http://localhost:4567](http://localhost:4567) start the server with:

> `./scripts/start.sh`

This port will be running a web application that was developed as a prototype in order to test and experience the recommendations.

The URL structured as `/usuário/_iddousuario_` allows you to simulate the access to any user recommendations.

![Web app](readme/screen-shot-1.png)

One motivation for the prototype development was to test queries using the user *context*. Below the main recommendations in the Home page you can see recommendations divided into categories he/her has shown interest in, the query made to ElasticSearch uses the navigation history of the user but gives greater weight to the category being seen.

The recommendation of similar videos (by clicking on any of the videos) is made using the item *tags*, so the search engine can find the most relevant similar documents. So it's a *Content Filtered* recommendation, since it does not use any information about the user behavior.

Similarly, the recommendation of similar shows uses the search engine to find the most relevant documents according to the textual description of the selected show.

#### Precomputed Similarities and "cold start"

In the prototype the navigation history is driven by *cookies*, that way you can navigate through videos and simulate a live environment.

The approach of pre-computing and storing similarities between items is ideal for real time recommendations, since processing is anticipated and thus does not interfere with the user experience with the product.

One has to find a way to deliver recommendations also to users who access the system for the first time. When the similarities are *user-based* it is necessary that user preferences are present during the model training, and therefore it is possible to observe a situation known as **"cold start"**: when you can not find relevant recommendations due to the lack of data.

*Item-based* similarities can be pre-computed thereby allow relevant recommendations to be delivered even though no information about the user was present at the model training time.

## Known Issues

In the current implementation scripts end up reading and writing files to disk, which is a lengthy process and can be a serious problem with larger volumes of data. It may be necessary to use something like [HDFS](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html) or to search for better ways to handle such situation.

Possible experiments:

* Diversify recommendations so they don't repeat so often;
* Use in the queries only the recent history of the user; but use the full history for model training.

[1]: https://www.mapr.com/blog/inside-look-at-components-of-recommendation-engine
[2]: https://www.mapr.com/blog/mahout-spark-what%E2%80%99s-new-recommenders
[3]: http://spectrum.ieee.org/computing/software/deconstructing-recommender-systems
[4]: https://www.mapr.com/products/mapr-sandbox-hadoop/tutorials/recommender-tutorial
[PracticalMachineLearning.pdf] http://info.mapr.com/rs/mapr/images/PracticalMachineLearning.pdf