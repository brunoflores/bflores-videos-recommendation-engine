package com.bruno.Recommender.evaluation.videos;

import java.io.File;
import java.io.IOException;

import org.apache.commons.cli2.OptionException;
import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.cf.taste.eval.IRStatistics;
import org.apache.mahout.cf.taste.eval.RecommenderBuilder;
import org.apache.mahout.cf.taste.eval.RecommenderIRStatsEvaluator;
import org.apache.mahout.cf.taste.impl.eval.GenericRecommenderIRStatsEvaluator;
import org.apache.mahout.cf.taste.impl.model.file.FileDataModel;
import org.apache.mahout.cf.taste.impl.recommender.GenericBooleanPrefItemBasedRecommender;
import org.apache.mahout.cf.taste.impl.similarity.CachingItemSimilarity;
import org.apache.mahout.cf.taste.impl.similarity.PearsonCorrelationSimilarity;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.recommender.Recommender;
import org.apache.mahout.cf.taste.similarity.ItemSimilarity;

public class EvalPearsonCorrelationSimilarity {
	public static void main(String... args) throws IOException, TasteException, OptionException {
		RecommenderIRStatsEvaluator evaluator = new GenericRecommenderIRStatsEvaluator();
		DataModel model = new FileDataModel(new File("data/videos_1_20.csv"));
		
		IRStatistics evaluation = evaluator.evaluate(
				new PearsonCorrelationRecommenderBuilder(), null, model, null, 5, 
				Double.NEGATIVE_INFINITY, 1.0);
		System.out.println(String.valueOf(evaluation));
		
		evaluation = evaluator.evaluate(
				new PearsonCorrelationRecommenderBuilder(), null, model, null, 10, 
				Double.NEGATIVE_INFINITY, 1.0);
		System.out.println(String.valueOf(evaluation));
		
		evaluation = evaluator.evaluate(
				new PearsonCorrelationRecommenderBuilder(), null, model, null, 20, 
				Double.NEGATIVE_INFINITY, 1.0);
		System.out.println(String.valueOf(evaluation));
	}
}

class PearsonCorrelationRecommenderBuilder implements RecommenderBuilder {
	public Recommender buildRecommender(DataModel dataModel) throws TasteException {
		ItemSimilarity itemSimilarity = new PearsonCorrelationSimilarity(dataModel);
		return new GenericBooleanPrefItemBasedRecommender(dataModel, 
				new CachingItemSimilarity(itemSimilarity, dataModel));
	}
}
