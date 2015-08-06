package com.bruno.Recommender;

import java.io.File;

import org.apache.mahout.cf.taste.impl.model.file.FileDataModel;
import org.apache.mahout.cf.taste.impl.recommender.GenericBooleanPrefItemBasedRecommender;
import org.apache.mahout.cf.taste.impl.similarity.CachingItemSimilarity;
import org.apache.mahout.cf.taste.impl.similarity.TanimotoCoefficientSimilarity;
import org.apache.mahout.cf.taste.impl.similarity.precompute.FileSimilarItemsWriter;
import org.apache.mahout.cf.taste.impl.similarity.precompute.MultithreadedBatchItemSimilarities;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.recommender.ItemBasedRecommender;
import org.apache.mahout.cf.taste.similarity.ItemSimilarity;
import org.apache.mahout.cf.taste.similarity.precompute.BatchItemSimilarities;

public class Videos {
	public static void main(String[] args) throws Exception {
		String tmpPath = "../../data/tmp";
		
		File resultFile = new File(tmpPath + "/similarities.csv");
		if (resultFile.exists()) resultFile.delete();
		DataModel dataModel = new FileDataModel(new File(tmpPath + "/mahout_ready/part-r-00000"));
		
		ItemSimilarity itemSimilarity = new TanimotoCoefficientSimilarity(dataModel);
		ItemBasedRecommender recommender = new GenericBooleanPrefItemBasedRecommender(dataModel, 
				new CachingItemSimilarity(itemSimilarity, dataModel));
		
		BatchItemSimilarities batch = new MultithreadedBatchItemSimilarities(recommender, 5);
		int numSimilarities = batch.computeItemSimilarities(Runtime
				.getRuntime().availableProcessors(), 1,
				new FileSimilarItemsWriter(resultFile));
		
		System.out.println("Computed " + numSimilarities + " similarities for "
				+ dataModel.getNumItems() + " items " + "and saved them to "
				+ resultFile.getAbsolutePath());
	}
}
