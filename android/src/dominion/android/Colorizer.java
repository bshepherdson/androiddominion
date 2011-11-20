package dominion.android;

import java.util.ArrayList;

import android.text.Spannable;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.widget.TextView;
import dominion.Card;
import dominion.CardTypes;

public class Colorizer {
	// Replacement for setText that handles colorizing card names.
	// DOES NOT expect three-word card names, maximum of two for now.
	public static void colorize(TextView tv, String s) {
		ArrayList<Word> words = new ArrayList<Word>();

		int start = -1;
		for(int i = 0; i < s.length(); i++) {
			if(Character.isLetter(s.charAt(i))) {
				if(start < 0) { // new word
					start = i;
				} // otherwise just keep adding to that word
			} else {
				if(start >= 0 && start != i) { // new word to add
					words.add(new Word(s.substring(start, i), start, i));
					start = -1;
				}
			}
		}
		
		if (start >= 0) {
			words.add(new Word(s.substring(start), start, s.length()));
		}
		
		for(Word w : words) {
			Log.i(Constants.TAG, w.toString());
		}
		
		tv.setText(s, TextView.BufferType.SPANNABLE);
		Spannable sp = (Spannable) tv.getText();
		
		Log.i(Constants.TAG, "Spannable: " + sp);

		for(int i = 0; i < words.size(); i++) {
			Word w = words.get(i);
			Card c;
			if((c = Card.cards(w.word)) != null) {
				sp.setSpan(new ForegroundColorSpan(Colorizer.getColor(c)), w.start, w.end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
			} else if(i+1 < words.size() && 
					(c = Card.cards(w.word + " " + words.get(i+1).word)) != null) {
				sp.setSpan(new ForegroundColorSpan(Colorizer.getColor(c)), w.start, words.get(i+1).end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
				i++; // jump over that word
			}
		}
	}
	
	private static int getColor(Card c) {
		if((c.types() & CardTypes.VICTORY) > 0)
			return 0xff00cc00;
		else if((c.types() & CardTypes.DURATION) > 0)
			return 0xfff87217;
		else if((c.types() & CardTypes.CURSE) > 0)
			return 0xffE45E9D;
		else if((c.types() & CardTypes.TREASURE) > 0)
			return 0xfffffc17;
		else if((c.types() & CardTypes.REACTION) > 0)
			return 0xff1589FF;
		else if((c.types() & CardTypes.ATTACK) > 0)
			return 0xffE42217;
		else
			return 0xffffffff;
	}
	
	private static class Word {
		public int start, end;
		public String word;
		
		public Word(String word, int start, int end) {
			this.word = word;
			this.start = start;
			this.end = end;
		}
		
		public String toString() {
			return "Word<" + word + ", " + start + ", " + end + ">";
		}
	}
}
