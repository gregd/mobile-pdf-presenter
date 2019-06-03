package com.grw.mobi.ui;

import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import com.grw.mobi.R;
import com.grw.mobi.presenters.RepoFilePresenter;
import com.grw.mobi.services.RepoService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RepoViewHtmlActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(RepoViewHtmlActivity.class);

    // params
    String repoName;
    String relPath;

    // models
    RepoService repoService;
    RepoFilePresenter htmlPres;

    // views
    WebView webView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.repo_view_html_activity_dl);

        Intent i = getIntent();
        repoName = i.getStringExtra("repo_name");
        relPath = i.getStringExtra("rel_path");
        logger.debug("onCreate {} {}", repoName, relPath);

        setActionBarTitle(buildTitle(relPath));

        loadModels();
        findViews();
        updateViews();
    }

    private String buildTitle(String relPath) {
        return relPath;
    }

    public void refreshUI(boolean restorePosition) {
    }

    private void loadModels() {
        repoService = new RepoService(getApplicationContext(), mConfig, orm, repoName);
        htmlPres = repoService.getFile(relPath);
    }

    private void findViews() {
        webView = (WebView) findViewById(R.id.repo_view_webview);
    }

    private void updateViews() {
        WebSettings settings = webView.getSettings();
        settings.setDefaultTextEncodingName("utf-8");

        webView.setWebViewClient(new WebViewClient() {
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                logger.warn("onReceivedError " + errorCode + " " + description);
                Toast.makeText(
                        RepoViewHtmlActivity.this,
                        description,
                        Toast.LENGTH_LONG).show();
            }
        });

        // TODO handle null values
        webView.loadUrl("file://" + htmlPres.getFile().getAbsolutePath());
    }

}


