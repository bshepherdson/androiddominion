package dominion.android;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import dominion.Decision;
import dominion.Exchange;
import dominion.Option;
import dominion.Player;
import dominion.android.GameService.GameBinder;

public class DominionA extends Activity {
	private Exchange exchange;
	boolean serviceBound = false;
	private Player lastPlayer = null;
	
	protected TextView newPlayer;
	protected LinearLayout infoLayout, optionsLayout, decisionLayout;
	
	protected int lastClick = -1;
	protected TextView lastClickTarget; 

	private OnClickListener optionListener = new OnClickListener() {
		public void onClick(View v) {
			TextView tv = (TextView) v;
			int index = ((Integer) tv.getTag()).intValue();
			
			if(index != lastClick) {
				if(lastClickTarget != null) {
					lastClickTarget.setTextColor(0xffdddddd);
				}
				tv.setTextColor(0xff00dd00);
				lastClickTarget = tv;
				lastClick = index;
			} else {
				// actually send the response.
				lastClick = -1; // reset to prevent one-click decisions.
				Exchange ex = DominionA.this.exchange;
				Decision decision = (Decision) ex.decision;
				Option opt = (Option) decision.options().get(index);
				ex.postResponse(opt.key());
				DominionA.this.handleDecision();
			}
		}
	};
	
	private ServiceConnection mConnection = new ServiceConnection() {
		public void onServiceConnected(ComponentName className, IBinder service) {
			// This is called when the connection with the service has been
			// established, giving us the object we can use to
			// interact with the service.
			Log.i(Constants.TAG, "Bound. service = " + service);
			exchange = ((GameBinder) service).exchange;
			serviceBound = true;
			DominionA.this.handleDecision();
		}

		public void onServiceDisconnected(ComponentName className) {
			// This is called when the connection with the service has been
			// unexpectedly disconnected -- that is, its process crashed.
			Toast.makeText(getApplicationContext(), "Fatal error: Service connection lost!", Toast.LENGTH_SHORT).show();
		}
	};

	protected void handleDecision() {
		Log.i(Constants.TAG, "Calling waitForDecision.");
		exchange.waitForDecision();
		Log.i(Constants.TAG, "waitForDecision returned");
		Decision decision = (Decision) exchange.decision;

		// display the show-to-player-X if it's not the same player as last time.
		if(decision.player() != lastPlayer) {
			decisionLayout.setVisibility(View.GONE);
			lastPlayer = decision.player();
			newPlayer.setText("Please give the phone to " + decision.player().name() + ".\nTap here to continue.");
			newPlayer.setVisibility(View.VISIBLE);
			Log.i(Constants.TAG, "Showing new player screen");
		} else {
			showDecision();
		}
	}
	
	
	protected void showDecision() {
		Decision decision = (Decision) exchange.decision;
		
		TextView playerName = (TextView) findViewById(R.id.playerName);
		playerName.setText(decision.player().name());
		
		TextView message = (TextView) findViewById(R.id.message);
		message.setText(decision.message());
		
		infoLayout.removeAllViews();
		for(int i = 0; i < decision.info().size(); i++) {
			TextView t = new TextView(this);
			t.setText((String) decision.info().get(i));
			t.setTextSize(TypedValue.COMPLEX_UNIT_PT, 6);
			infoLayout.addView(t);
		}
		
		optionsLayout.removeAllViews();
		for(int i = 0; i < decision.options().size(); i++) {
			Option o = (Option) decision.options().get(i);
			TextView t = new TextView(this);
			t.setText(o.text());
			t.setTextSize(TypedValue.COMPLEX_UNIT_PT, 8);
			t.setClickable(true);
			t.setTag(new Integer(i));
			t.setOnClickListener(optionListener);
			
			LinearLayout.LayoutParams llp = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		    llp.setMargins(0, 10, 0, 0); // llp.setMargins(left, top, right, bottom);
		    t.setLayoutParams(llp);
			
			optionsLayout.addView(t);
		}
		
		decisionLayout.setVisibility(View.VISIBLE);
		Log.i(Constants.TAG, "Decision visible");
	}
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Log.i(Constants.TAG, "DominionA.onCreate");
		setContentView(R.layout.dominion);
		newPlayer = (TextView) findViewById(R.id.newPlayer);
		newPlayer.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.i(Constants.TAG, "New player screen clicked, showing decision");
				DominionA.this.newPlayer.setVisibility(View.GONE);
				DominionA.this.showDecision();
			}
		});
		
		infoLayout = (LinearLayout) findViewById(R.id.infoLayout);
		optionsLayout = (LinearLayout) findViewById(R.id.optionsLayout);
		decisionLayout = (LinearLayout) findViewById(R.id.decision);
	}

	@Override
	protected void onStart() {
		super.onStart();
		// Bind to the service
		Log.i(Constants.TAG, "DominionA.onStart. Calling bindService.");
		bindService(new Intent(this.getApplicationContext(), GameService.class), mConnection,
				Context.BIND_AUTO_CREATE);
	}

	@Override
	protected void onStop() {
		super.onStop();
		// Unbind from the service
		if (serviceBound) {
			unbindService(mConnection);
			serviceBound = false;
		}
	}
}
