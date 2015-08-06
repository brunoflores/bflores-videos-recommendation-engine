package com.bruno.Recommender.evaluation.shows;

import java.io.File;
import java.io.IOException;

import org.apache.commons.cli2.OptionException;
import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.cf.taste.eval.RecommenderBuilder;
import org.apache.mahout.cf.taste.impl.eval.AverageAbsoluteDifferenceRecommenderEvaluator;
import org.apache.mahout.cf.taste.impl.eval.RMSRecommenderEvaluator;
import org.apache.mahout.cf.taste.impl.model.file.FileDataModel;
import org.apache.mahout.cf.taste.impl.recommender.GenericItemBasedRecommender;
import org.apache.mahout.cf.taste.impl.similarity.CachingItemSimilarity;
import org.apache.mahout.cf.taste.impl.similarity.LogLikelihoodSimilarity;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.recommender.Recommender;
import org.apache.mahout.cf.taste.similarity.ItemSimilarity;

public class EvalLogLikelihoodSimilarity {
	public static void main(String... args) throws IOException, TasteException, OptionException {
		DataModel model = new FileDataModel(new File("data/users_shows.csv"));
		
		RMSRecommenderEvaluator RMSevaluator = new RMSRecommenderEvaluator();
		double RMSevaluation = RMSevaluator.evaluate(
				new LogLikelihoodRecommenderBuilder(), null, model, 0.5, 1.0);
		System.out.println("RMS: " + String.valueOf(RMSevaluation));
		
		AverageAbsoluteDifferenceRecommenderEvaluator MAEevaluator = new AverageAbsoluteDifferenceRecommenderEvaluator();
		double MAEevaluation = MAEevaluator.evaluate(
				new LogLikelihoodRecommenderBuilder(), null, model, 0.5, 1.0);
		System.out.println("MAE: " + String.valueOf(MAEevaluation));
	}
}

class LogLikelihoodRecommenderBuilder implements RecommenderBuilder {
	public Recommender buildRecommender(DataModel dataModel) throws TasteException {
		ItemSimilarity itemSimilarity = new LogLikelihoodSimilarity(dataModel);
		return new GenericItemBasedRecommender(dataModel, 
				new CachingItemSimilarity(itemSimilarity, dataModel));
	}
}
