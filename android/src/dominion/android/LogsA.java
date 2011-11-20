package dominion.android;

import java.util.ArrayList;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import dominion.Exchange;

public class LogsA extends Activity {
	ScrollView scroller;
	
	@Override
	protected void onCreate(Bundle payload) {
		super.onCreate(payload);
		Log.i(Constants.TAG, "LogsA.onCreate");
		setContentView(R.layout.logs);
		
		Exchange exchange = Constants.exchange;
		ArrayList<String> logs = exchange.getLogs();
		Log.i(Constants.TAG, "LogsA: logs retrieved, " + logs);
		
		LinearLayout layout = (LinearLayout) findViewById(R.id.logsLayout);
		
		for(String s : logs) {
			TextView t = new TextView(this);
			Colorizer.colorize(t, s);
			layout.addView(t);
		}
		
		scroller = (ScrollView) findViewById(R.id.logsScroller);
		
	}
	
	@Override
	protected void onStart() {
		super.onStart();
		
		scroller.post(new Runnable() {
			@Override
			public void run() {
				LogsA.this.scroller.fullScroll(ScrollView.FOCUS_DOWN);
			}
		});
	}
	
}
