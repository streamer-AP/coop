文档 https://app.apifox.com/project/7391709

# APP接口

1. 注册、登录、设置密码、修改密码、忘记密码、注销（6个+4个验证码)
2. 协议（2个）

   1. 根据资源key查看代确认的最新版本的协议
   2. 确认协议
3. 绑定兑换码并赋值权限(1个)
4. 当前用户权限相关（1个）

   - 获取当前用户的所有权限，包含权限code和类型（注意：如果当前用户是黑名单，看不到任何资源，如果当前用户是白名单，所有权限的数据而不是用户关联的权限+用户兑换码的权限）
5. 权限资源（2个）

   - 查看全局的资源list（数据：用户的权限中没有角色的权限数据，返回：按照场景和类型分组的角色资源）(主页和背景音乐场景)

   - 查看角色的资源list（数据：用户的权限中有角色的权限数据，返回：权限的角色资源，权限的角色，权限角色对应的角色资源（卡片场景）\故事list）
6. 剧情故事相关（4个）

   - 按照角色，查看剧情故事list。每个剧情故事包含对应的角色资源list（故事场景）
   - 根据故事id，查询对应的角色资源list（故事场景）
   - 按照故事，查询故事的检查点list。每个检查点包含是否完成。
   - 故事完成检查点（批量：每个剧情故事的检查点一条数据。） 
7. 文件和资源（2个）

   1. 根据角色资源序列号resource_sn，重定向角色资源的下载地址（1个）ok
   2. 查看企业资源信息数据（批量：根据资源键值查的主数据的企业资源信息）（1个）  ok
8. 其他
   1. app日志（错误、操作）（批量:每一次记录一条日志）(2个) 
   2. 根据时间获取邮件list





# 复杂接口说明

~~~

~~~





#### 解密逻辑

#### 1、 文件下载路径获取

调用应用服务接口（7.1）

~~~
GET /encrypted/downloadUrl/{resourceSn}
重定向到实际文件下载地址
https://et-app-test.oss-cn-shanghai.aliyuncs.com/source-encrypt/2025/11/15/16/1763196684983_rsrczhl_test010202511151643091c0.bin?Expires=1763213450&OSSAccessKeyId=LTAI5tM8nyCayQUWBedLhhZB&Signature=RlWg6GaGnEtDpIfTTJTRj11ifbw%3D
~~~



#### 2、 oos文件响应头

| accept-ranges                | bytes                              | 说明                   |
| ---------------------------- | ---------------------------------- | ---------------------- |
| content-disposition          | attachment                         |                        |
| content-length               | 19279                              | 文件大小               |
| content-md5                  | RTdgaUGZoyNA+IemGL2EaA==           | 加密文件md5 可用于缓存 |
| content-type                 | application/octet-stream           | 加密文件格式           |
| date                         | Sat, 15 Nov 2025 12:31:12 GMT      |                        |
| etag                         | "453760694199A32340F887A618BD8468" |                        |
| last-modified                | Sat, 15 Nov 2025 08:51:25 GMT      |                        |
| server                       | AliyunOSS                          |                        |
| x-oss-ec                     | 0048-00000113                      |                        |
| x-oss-force-download         | true                               |                        |
| x-oss-hash-crc64ecma         | 16062772500274890824               |                        |
| x-oss-meta-encrypt-algorithm | AES-256-GCM                        | 加密算法               |
| x-oss-meta-encrypted         | true                               | 是否加密               |
| x-oss-meta-original-filename | response.json                      | 原始文件名（包含后缀） |
| x-oss-meta-resource-name     | OMAO                               | 密钥前缀               |
| x-oss-meta-resource-sn       | rsrczhl_test010202511151643091c0   | 资源sn                 |
| x-oss-meta-resource-version  | v1                                 | 密钥版本v1             |
| x-oss-object-type            | Normal                             |                        |
| x-oss-request-id             | 69187290E3C8F73533805028           |                        |
| x-oss-server-time            | 82                                 |                        |
| x-oss-storage-class          | Standard                           |                        |





#### 3、 主密钥生成逻辑

规则

~~~properties
从文件的响应头获取如下三个值拼接
规则: 密钥前缀_密钥版本_资源sn
示例: OMAO_v1_rsrczhl_test010202511151643091c0
~~~

代码

~~~java
// 规则: 密钥前缀_密钥版本v1_资源sn
String masterKeyStr = String.format("%s_v%s_%s", 
                                    /*密钥前缀*/resourceName,  
                                    /*密钥版本*/resourceVersion, 
                                    /*资源sn*/ resourceSn);
~~~



#### 4、 加密解密方法

详见decrypt方法

~~~java
package com.example.webapp.encrypt.util;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

@Slf4j
public class OssDataEncryptorUtil {

    private static String SALT_STR = "resource";
    // 固定盐值
    private static final byte[] SALT = SALT_STR.getBytes(StandardCharsets.UTF_8);

    // GCM推荐IV长度
    private static final int GCM_IV_LENGTH = 12;

    // 认证标签长度
    private static final int GCM_TAG_LENGTH = 16*8;

    private static final String ALGORITHM = "AES/GCM/NoPadding";


    @Data
    public static class OssDataEncryptorRes {

        private byte[] encryptedData;

        /**
         * Base64编码的IV
         */
        private String iv;

        /**
         * 加密算法
         */
        private String algorithm;

        /**
         * 主密钥
         */
        private String encryptKey;

        /**
         * 盐值
         */
        private String encryptSalt;
    }
    /**
     * 生成主密钥（基于资源序列号）
     */
    private static SecretKey generateMasterKey(String masterKeyStr) throws Exception {

        byte[] keyBytes = masterKeyStr.getBytes(StandardCharsets.UTF_8);

        // 使用SHA-256生成固定长度密钥
        byte[] derivedKey = MessageDigest.getInstance("SHA-256")
                .digest(ByteBuffer.allocate(SALT.length  + keyBytes.length)
                        .put(SALT)
                        .put(keyBytes)
                        .array());

        return new SecretKeySpec(derivedKey, "AES");
    }

    /**
     * 加密数据
     * @param cipherText 加密的数据
     * @param masterKeyStr 主密钥
     * @return 加密后的数据
     */
    public static OssDataEncryptorRes encrypt(byte[] cipherText, String masterKeyStr) {
        try {

            // 加盐生成主密钥
            SecretKey secretKey = generateMasterKey(masterKeyStr);

            // 生成随机IV
            byte[] iv = new byte[GCM_IV_LENGTH];
            new SecureRandom().nextBytes(iv);

            // 初始化加密器
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE,  secretKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));

            // 执行加密
            byte[] encryptedData = cipher.doFinal(cipherText);

            // 组合IV+密文
            byte[] allEncryptedData = ByteBuffer.allocate(iv.length  + encryptedData.length)
                    .put(iv)
                    .put(encryptedData)
                    .array();

            // 组装数据
            OssDataEncryptorRes res = new OssDataEncryptorRes();
            res.setIv(Base64.getEncoder().encodeToString(iv));
            res.setAlgorithm(ALGORITHM);
            res.setEncryptSalt(SALT_STR);
            res.setEncryptKey(masterKeyStr);
            res.setEncryptedData(allEncryptedData);
            res.setIv(Base64.getEncoder().encodeToString(iv));
            log.info("文件加密成功，资源序列号：{}，文件大小：{}字节", masterKeyStr, allEncryptedData.length);

            return res;
        } catch (Exception e) {

            log.error("文件加密失败，资源序列号：{}", masterKeyStr, e);
            throw new RuntimeException("文件加密失败", e);
        }
    }

    /**
     * 解密数据
     * @param encryptedData 加密后数据
     * @param masterKeyStr 主密钥
     * @return 解密后数据
     */
    public static byte[] decrypt(byte[] encryptedData, String masterKeyStr)  {

        try {
            // 分离IV和密文
            ByteBuffer buffer = ByteBuffer.wrap(encryptedData);
            byte[] iv = new byte[GCM_IV_LENGTH];
            buffer.get(iv);
            byte[] cipherText = new byte[buffer.remaining()];
            buffer.get(cipherText);

            // 生成主密钥
            SecretKey secretKey = generateMasterKey(masterKeyStr);

            // 初始化解密器
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE,  secretKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));

            // 执行解密
            byte[] plainText = cipher.doFinal(cipherText);
            log.info(" 文件解密成功，原始大小：{}字节", plainText.length);
            return plainText;
        } catch (Exception e) {
            log.error(" 文件解密失败：认证标签验证不通过或密钥错误", e);
            throw new SecurityException("解密失败：数据可能被篡改或密钥无效");
        }

    }

    // 测试
    public static void main(String[] args) {
        // 拼接资源序列号
        String masterkeyStr = "OMAO-/我的1234名字_v1.0.0_001012332132134";
        String original = "v1资源序列号加盐的加密解密测试v1资源序列号加盐的加密解密测试v1资源序列号加盐的加密解密测试";
        byte[] encryptedData = original.getBytes(StandardCharsets.UTF_8);
        System.out.println("原始数据:  " + original);

        // 加密
        OssDataEncryptorRes encrypt = encrypt(encryptedData, masterkeyStr);
        byte[] encrypted = encrypt.getEncryptedData();
        System.out.println("加密数据:  " + Base64.getEncoder().encodeToString(encrypted));

        // 解密
        byte[] decrypted = decrypt(encrypted, masterkeyStr);
        String output = new String(decrypted, StandardCharsets.UTF_8);
        System.out.println("解密数据:  " +output);

        // 验证
        System.out.println("匹配结果:  " + original.equals(output));
    }
}
~~~



根据响应头的原始文件名称写入文件

~~~
略
~~~

文件测试

~~~
加密后文件
https://et-app-test.oss-cn-shanghai.aliyuncs.com/source-encrypt/2025/11/15/21/1763212889567_rsrczhl_test010202511151643091c0.bin?Expires=1763216514&OSSAccessKeyId=LTAI5tM8nyCayQUWBedLhhZB&Signature=RLaZExhqkq0WWqUDK72gHIK0QEk%3D
实际文件： 一张图片
~~~



