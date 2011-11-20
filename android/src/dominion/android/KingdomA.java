package dominion.android;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import android.widget.TextView;
import dominion.Game;
import dominion.Kingdom;

public class KingdomA extends Activity {
	ArrayList<Kingdom> kingdom;
	
	@SuppressWarnings("unchecked")
	@Override
	protected void onCreate(Bundle payload) {
		super.onCreate(payload);
		setContentView(R.layout.kingdom);
		
		kingdom = (ArrayList<Kingdom>) Game.instance().kingdom();
		
		LinearLayout layout = (LinearLayout) findViewById(R.id.kingdomLayout);
		
		for(int i = 0; i < kingdom.size(); i++) {
			Kingdom k = kingdom.get(i);
			TextView t = new TextView(this);
			Colorizer.colorize(t, k.card().name() + ": " + k.card().cost() + " Coins, " + k.count() + " remaining.");
			t.setTextSize(TypedValue.COMPLEX_UNIT_PT, 8);
			t.setOnClickListener(clickListener);
			t.setTag(new Integer(i));
			layout.addView(t);
		}
	}
	
	OnClickListener clickListener = new OnClickListener() {
		public void onClick(View clicked) {
			int index = ((Integer) clicked.getTag()).intValue();
			Intent i = new Intent(KingdomA.this.getApplicationContext(), CardA.class);
			i.putExtra("index", new Integer(index));
			startActivity(i);
		}
	};
}
