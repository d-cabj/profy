class User < ActiveRecord::Base
  # ActiveRecordを継承したクラスの場合自動でテーブルのカラム名がプロパティとして定義されます。今回のようにフォームへ新たに、カラムとしては存在しないプロパティを追加するためにはattr_accessorをUserモデルに追加する必要があります。
  attr_accessor :group_key
  belongs_to :group
  has_many :questions, ->{order("created_at desc")}
  # -> はlambda(ラムダ)記法という。lambdaは匿名関数のことを指し、アソシエーションでオプション指定をする際に用います。
  has_many :answers, ->{ order("updated_at DESC") }
  has_many :answered_questions, through: :answers, source: :question

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, authentication_keys: [:email, :group_key]

  #validation
  before_validation :group_key_to_id, if: :has_group_key?

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    group_key = conditions.delete(:group_key)
    group_id = Group.where(key: group_key).first
    email = conditions.delete(:email)

    # devise認証を、複数項目に対応させる
    if group_id && email
      where(conditions).where(["group_id = :group_id AND email = :email",
        { group_id: group_id, email: email }]).first
    elsif conditions.has_key?(:confirmation_token)
      where(conditions).first
    else
      false
    end
  end

  def name
    "#{family_name} #{first_name}"
  end

  def name_kana
    "#{family_name_kana} #{first_name_kana}"
  end

  def full_profile?
    avatar? && family_name? && first_name? && family_name_kana? && first_name_kana?
  end

# paperclipsetting
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>"}
  validates_attachment_content_type :avatar, content_type: ["image/jpg","image/jpeg","image/png"]

  private
  def has_group_key?
    group_key.present?
  end

  def group_key_to_id
    group = Group.where(key: group_key).first_or_create
    self.group_id = group.id
  end
end
