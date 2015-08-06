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
import org.apache.mahout.cf.taste.impl.recommender.RandomRecommender;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.recommender.Recommender;

public class EvalRandomRecommender {
	public static void main(String... args) throws IOException, TasteException, OptionException {
		RecommenderIRStatsEvaluator evaluator = new GenericRecommenderIRStatsEvaluator();
		DataModel model = new FileDataModel(new File("data/videos_1_20.csv"));
		
		IRStatistics evaluation = evaluator.evaluate(
				new RandomRecommenderBuilder(), null, model, null, 5, 
				Double.NEGATIVE_INFINITY, 1.0);
		System.out.println(String.valueOf(evaluation));
		
		evaluation = evaluator.evaluate(
				new RandomRecommenderBuilder(), null, model, null, 10, 
				Double.NEGATIVE_INFINITY, 1.0);
		System.out.println(String.valueOf(evaluation));
		
		evaluation = evaluator.evaluate(
				new RandomRecommenderBuilder(), null, model, null, 20, 
				Double.NEGATIVE_INFINITY, 1.0);
		System.out.println(String.valueOf(evaluation));
	}
}

class RandomRecommenderBuilder implements RecommenderBuilder {
	public Recommender buildRecommender(DataModel dataModel) throws TasteException {
		return new RandomRecommender(dataModel);
	}
}
