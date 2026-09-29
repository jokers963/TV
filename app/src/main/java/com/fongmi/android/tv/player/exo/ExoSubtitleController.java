package com.fongmi.android.tv.player.exo;

import androidx.annotation.Nullable;
import androidx.media3.common.TrackSelectionOverride;
import androidx.media3.ui.PlayerView;

import com.fongmi.android.tv.player.engine.PlayerEngine.SecondarySubtitleState;
import com.fongmi.android.tv.setting.SubtitleSetting;

final class ExoSubtitleController {

    private PlayerView playerView;

    ExoSubtitleController(ExoPlayerSession session) {
        applySubtitleStyle();
    }

    void release() {
    }

    void bindPlayerView(PlayerView playerView) {
        this.playerView = playerView;
        applySubtitleStyle();
    }

    void applySubtitleStyle() {
        if (playerView != null) SubtitleSetting.applyStyle(playerView.getSubtitleView());
    }

    SecondarySubtitleState getSecondarySubtitleState() {
        return SecondarySubtitleState.EMPTY;
    }

    void setSecondarySubtitleSelection(@Nullable TrackSelectionOverride selection) {
    }
}
