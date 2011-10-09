package dominion.android;

import java.util.ArrayList;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import dominion.Card;
import dominion.Exchange;
import dominion.Game;
import dominion.Logger;

public class GameService extends Service {

	public boolean isStarted = false;
	private ServiceThread thread;
	private Exchange exchange;
	
	@Override
	public int onStartCommand(Intent intent, int flags, int startId){
		Constants.service = this;
		Notification notification = new Notification(R.drawable.icon, getText(R.string.ticker_text),
		        System.currentTimeMillis());
		Intent notificationIntent = new Intent(this, DominionA.class);
		PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
		notification.setLatestEventInfo(this, getText(R.string.notification_title),
		        getText(R.string.notification_message), pendingIntent);
		

		Bundle extras = intent.getExtras();
		
		Logger logger = new LogcatLogger(); 
		exchange = new Exchange();
		exchange.setLogger(logger);
		thread = new ServiceThread(exchange, extras.getStringArrayList("players"), this);
		isStarted = true;
		Log.i(Constants.TAG, "onStartCommand, isStarted = true");
		
		startForeground(Constants.ONGOING_NOTIFICATION, notification);
		
		
		return 0;
	}
	
	public class LogcatLogger implements Logger {
		public void log(String s) {
			Log.e(Constants.TAG, s);
		}
	}
	
	public class GameBinder extends Binder {
		public Exchange exchange;
		
		public GameBinder(Exchange exchange) {
			this.exchange = exchange;
		}
	}
	
	@Override
	public IBinder onBind(Intent intent) {
		Log.i(Constants.TAG, "GameService.onBind");
		if(isStarted) {
			thread.start();
			Log.i(Constants.TAG, "Returning " + exchange);
			return new GameBinder(exchange);
		}
		Log.i(Constants.TAG, "Returning null");
		return null;
	}
	
	private class ServiceThread extends Thread {
		private Exchange exchange;
		private ArrayList<String> players;
		private Service parent;
		
		public ServiceThread(Exchange exchange, ArrayList<String> players, Service s) {
			this.exchange = exchange;
			this.players = players;
			this.parent = s;
		}
		
		public void run() {
			// Set up the Dominion game
			Card.initializeCards();
			Game.bootstrap();
			Game.instance().exchange_set(exchange);
			for(String p : players) {
				Game.instance().addPlayer(p);
			}
			Game.instance().startGame();
			
			Log.i(Constants.TAG, "startGame called, about to call playTurn");
			
			while(!Game.instance().playTurn()) {
				Log.i(Constants.TAG, "Turn over, calling playTurn() again");
			}
			Log.i(Constants.TAG, "Game over!");
			
			parent.stopForeground(true);
			parent.stopService(new Intent(parent, GameService.class));
		}
	}
}
