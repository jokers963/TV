package com.github.catvod.net.interceptor;

import androidx.annotation.NonNull;

import com.google.common.net.HttpHeaders;

import java.io.IOException;

import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class PngTsInterceptor implements Interceptor {

    @NonNull
    @Override
    public Response intercept(@NonNull Chain chain) throws IOException {
        Response response = chain.proceed(chain.request());
        if (response.body() == null) return response;
        String type = response.header(HttpHeaders.CONTENT_TYPE, "").toLowerCase();
        if (!type.startsWith("image/png")) return response;
        MediaType originalType = response.body().contentType();
        byte[] body = response.body().bytes();
        int offset = findTsOffset(body);
        if (offset <= 0) return response.newBuilder().body(ResponseBody.create(originalType, body)).build();
        byte[] ts = new byte[body.length - offset];
        System.arraycopy(body, offset, ts, 0, ts.length);
        return response.newBuilder()
                .removeHeader(HttpHeaders.CONTENT_LENGTH)
                .header(HttpHeaders.CONTENT_TYPE, "video/mp2t")
                .body(ResponseBody.create(MediaType.parse("video/mp2t"), ts))
                .build();
    }

    static int findTsOffset(byte[] body) {
        if (body.length < 8 || body[0] != (byte) 0x89 || body[1] != 0x50 || body[2] != 0x4e || body[3] != 0x47
                || body[4] != 0x0d || body[5] != 0x0a || body[6] != 0x1a || body[7] != 0x0a) return -1;
        for (int i = 8; i + 376 < body.length; i++) {
            if (body[i] == 0x47 && body[i + 188] == 0x47 && body[i + 376] == 0x47) return i;
        }
        return -1;
    }
}
