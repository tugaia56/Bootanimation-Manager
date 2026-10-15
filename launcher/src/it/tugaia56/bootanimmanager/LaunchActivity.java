package it.tugaia56.bootanimmanager;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

/** Opens the WebUI of the Bootanimation Manager module straight from the app drawer, through the KsuWebUI app. */
public class LaunchActivity extends Activity {
    private static final String WEBUI_PKG = "io.github.a13e300.ksuwebui";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            Intent i = new Intent();
            i.setClassName(WEBUI_PKG, WEBUI_PKG + ".WebUIActivity");
            i.putExtra("id", "oxybootanim");
            i.putExtra("name", "Bootanimation Manager");
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(i);
        } catch (ActivityNotFoundException | SecurityException e) {
            Toast.makeText(this, "Install the KsuWebUI app first (io.github.a13e300.ksuwebui)", Toast.LENGTH_LONG).show();
        }
        finish();
    }
}
