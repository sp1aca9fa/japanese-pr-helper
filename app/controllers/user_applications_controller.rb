class UserApplicationsController < ApplicationController
  def index
    @user_applications = current_user.user_applications
  end

  def new
    @user_application = UserApplication.new
  end

  def create
    @user_application = UserApplication.new(user_application_params)
    @user_application.user = current_user
    if @user_application.save
      populate_chats(@user_application)
      redirect_to user_application_chat_path(@user_application, @user_application.chats.last)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    user_application = UserApplication.find(params[:id])
    user_application.destroy
    redirect_to user_applications_path, status: :see_other
  end

  private

  def populate_chats(user_application)
    titles = []
    case user_application.application_journey.application_road
    when "married"
      titles = [
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Proof of Relationships (身分関係を証明する書類)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        "List of Relatives (親族一覧表)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",
        "Acknowledgement Form (了解所)"
      ]
    when "long_term"
      titles = [
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Statement of Reasons (理由書)",
        "Proof of Relationships (身分関係を証明する書類)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        "Proof of Assets (資産を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",
        "Acknowledgement Form (了解所)"
      ]
    when "work"
      titles = [
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Statement of Reasons (理由書)",
        "Proof of Relationships (身分関係を証明する書類)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        "Proof of Assets (資産を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",
        "Acknowledgement Form (了解所)"
      ]
    when "highly1a"
      titles = [
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Statement of Reasons (理由書)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        "Highly Skilled Professional Points Calculation Table (高度専門職ポイント計算表)",
        "Proof for Points Calculation (ポイント計算の各項目に関する疎明資料)",
        "Proof of Assets (資産を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Acknowledgement Form (了解所)"
      ]
    when "highly1b"
      titles = [
        # shared
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Proof of Relationships (身分関係を証明する書類)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Acknowledgement Form (了解所)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",

        # # if married
        # "List of Relatives (親族一覧表)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # # if long_term
        # "Statement of Reasons (理由書)",
        # "Taxation Certificates (所得及び納税状況を証明する資料)",
        # "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        # "Proof of Assets (資産を証明する資料)",
        # "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # # if work
        # "Statement of Reasons (理由書)",
        # "Taxation Certificates (所得及び納税状況を証明する資料)",
        # "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        # "Proof of Assets (資産を証明する資料)",
        # "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # highly1b specific
        "Highly Skilled Professional Points Calculation Table (高度専門職ポイント計算表)",
        "Proof for Points Calculation (ポイント計算の各項目に関する疎明資料)"
      ]
    when "highly2a"
      titles = [
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Statement of Reasons (理由書)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        "Highly Skilled Professional Points Calculation Table (高度専門職ポイント計算表)",
        "Proof for Points Calculation (ポイント計算の各項目に関する疎明資料)",
        "Proof of Assets (資産を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",
        "Acknowledgement Form (了解所)"
      ]
    when "highly2b"
      titles = [
        # shared
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Proof of Relationships (身分関係を証明する書類)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Acknowledgement Form (了解所)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",

        # # if married
        # "List of Relatives (親族一覧表)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # # if long_term
        # "Statement of Reasons (理由書)",
        # "Taxation Certificates (所得及び納税状況を証明する資料)",
        # "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        # "Proof of Assets (資産を証明する資料)",
        # "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # # if work
        # "Statement of Reasons (理由書)",
        # "Taxation Certificates (所得及び納税状況を証明する資料)",
        # "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        # "Proof of Assets (資産を証明する資料)",
        # "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # highly2b specific
        "Highly Skilled Professional Points Calculation Table (高度専門職ポイント計算表)",
        "Proof for Points Calculation (ポイント計算の各項目に関する疎明資料)"
      ]
    when "special1"
      titles = [
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Statement of Reasons (理由書)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        "Specially Highly Skilled Personnel Certificate ()",
        "Proof of Annual Income (年収を証する文書)",
        "Proof of Assets (資産を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Acknowledgement Form (了解所)"
      ]
    when "special2"
      titles = [
        # shared
        "Application Form (永住許可申請書)",
        "Photograph (写真)",
        "Proof of Relationships (身分関係を証明する書類)",
        "Residence Certificate (住民票)",
        "Employment Certificate (職業を証明する資料)",
        "Passport or Certificate of Residence Status (パスポート（旅券）又は在留資格証明書)",
        "Residence Card (在留カード)",
        "Letter of Guarantee (身元保証書)",
        "Acknowledgement Form (了解所)",
        "Taxation Certificates (所得及び納税状況を証明する資料)",
        "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",

        # # if married
        # "List of Relatives (親族一覧表)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # # if long_term
        # "Statement of Reasons (理由書)",
        # "Taxation Certificates (所得及び納税状況を証明する資料)",
        # "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        # "Proof of Assets (資産を証明する資料)",
        # "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # # if work
        # "Statement of Reasons (理由書)",
        # "Taxation Certificates (所得及び納税状況を証明する資料)",
        # "Pension and Health Insurance Payment Records (公的年金及び公的医療保険の保険料の納付状況を証明する資料)",
        # "Proof of Assets (資産を証明する資料)",
        # "Proof of Contributions to Japan (日本国への貢献に係る資料)",
        # "Proof of Identity for Proxy (申請人以外の方の身分を証する文書)",

        # special2 specific
        "Proof of Academic/Work History (学歴又は職歴を証する文書)",
        "Proof of Annual Income (年収を証する文書)"
      ]
    end
    titles.reverse.each do |title|
      chat = Chat.new(title: title.gsub(" (", "\n("), system_prompt: title)
      chat.user_application = user_application
      chat.save
    end
  end

  def user_application_params
    params.require(:user_application).permit(:application_journey_id, :title)
  end
end
