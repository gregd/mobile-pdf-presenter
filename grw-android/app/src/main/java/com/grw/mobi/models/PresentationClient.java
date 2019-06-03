package com.grw.mobi.models;

import android.support.annotation.Nullable;

import com.grw.mobi.Config;
import com.grw.mobi.aorm.OrmDatabase;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.util.DateUtils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Date;

public class PresentationClient {
    private static final Logger logger = LoggerFactory.getLogger(PresentationClient.class);

    public Date updatedAt;
    public String type;
    public String uuid;
    public int lastEventId;

    public static void clear(Config config) {
        config.setPresentationClient(null, null, 0);
    }

    public static void clearAndCancel(Config config) {
        PresentationClient client = getWithTimeout(config);
        if (client == null) return;

        logger.debug("delete from id {} {} {}", client.type, client.uuid, client.lastEventId);
        clear(config);
        OrmSession orm = OrmDatabase.getInstance().defaultSession();
        orm.trackerFileEventDao.deleteFromId(client.lastEventId);
    }

    public static void set(Config config, OrmModel model) {
        OrmSession orm = OrmDatabase.getInstance().defaultSession();
        Integer lastId = orm.trackerFileEventDao.lastId();
        logger.debug("set {} {} {}", model.canonicalModel(), model.uuid, lastId);
        config.setPresentationClient(model.canonicalModel(), model.uuid, lastId == null ? 0 : lastId);
    }

    public static @Nullable OrmModel get(Config config) {
        PresentationClient client = getWithTimeout(config);
        if (client == null) return null;

        OrmSession orm = OrmDatabase.getInstance().defaultSession();
        return orm.findByNameUuidOrId(
                client.type,
                client.uuid,
                null);
    }

    private static @Nullable PresentationClient getWithTimeout(Config config) {
        PresentationClient client = config.getPresentationClient();
        if (client == null) return null;

        Date hourAgo = DateUtils.addHours(new Date(), -1);
        if (hourAgo.getTime() > client.updatedAt.getTime()) {
            logger.debug("timeout {} {} {}", client.type, client.uuid, client.lastEventId);
            config.setPresentationClient(null, null, 0);
            return null;
        }

        return client;
    }

}
