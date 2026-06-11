import Link from "next/link";

export default function HomePage() {
  return (
    <main className="container">
      <h1>ترددي — لوحة الإدارة</h1>
      <p style={{ color: "var(--grey)" }}>
        إدارة الخطوط والباصات والسائقين والرحلات النشطة
      </p>
      <nav className="nav">
        <Link href="/routes">الخطوط</Link>
        <Link href="/buses">الباصات</Link>
        <Link href="/drivers">السائقين</Link>
        <Link href="/trips">الرحلات</Link>
      </nav>
      <div className="card">
        <h3>تدفق العمل</h3>
        <ol>
          <li>أضف خطاً ومحطاته</li>
          <li>أضف باصاً</li>
          <li>أضف سائقاً وعيّن له خطاً وباصاً</li>
          <li>السائق يبدأ الرحلة ويرسل GPS</li>
          <li>الراكب يشوف الباص على الخريطة ويحدد تذكير</li>
        </ol>
      </div>
    </main>
  );
}
