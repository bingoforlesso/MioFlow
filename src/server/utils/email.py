import aiosmtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# 邮件服务器配置
SMTP_HOST = "smtp.example.com"  # 替换为实际的SMTP服务器
SMTP_PORT = 587
SMTP_USERNAME = "your-email@example.com"  # 替换为实际的邮箱账号
SMTP_PASSWORD = "your-password"  # 替换为实际的邮箱密码

async def send_reset_password_email(email: str, token: str, username: str):
    """
    发送密码重置邮件
    """
    message = MIMEMultipart()
    message["From"] = SMTP_USERNAME
    message["To"] = email
    message["Subject"] = "密码重置请求"

    # 创建重置链接
    reset_link = f"http://your-domain.com/reset-password?token={token}"

    # 邮件内容
    html_content = f"""
    <html>
        <body>
            <h2>密码重置请求</h2>
            <p>亲爱的 {username}：</p>
            <p>我们收到了您的密码重置请求。请点击下面的链接重置您的密码：</p>
            <p><a href="{reset_link}">{reset_link}</a></p>
            <p>此链接将在24小时后失效。如果您没有请求重置密码，请忽略此邮件。</p>
            <p>祝好，</p>
            <p>MioDing团队</p>
        </body>
    </html>
    """

    message.attach(MIMEText(html_content, "html"))

    try:
        # 连接到SMTP服务器并发送邮件
        async with aiosmtplib.SMTP(hostname=SMTP_HOST, port=SMTP_PORT, use_tls=True) as smtp:
            await smtp.login(SMTP_USERNAME, SMTP_PASSWORD)
            await smtp.send_message(message)
    except Exception as e:
        print(f"发送邮件失败: {str(e)}")
        raise